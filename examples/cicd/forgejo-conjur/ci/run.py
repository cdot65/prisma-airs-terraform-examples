#!/usr/bin/env python3
"""Forgejo entry point: retrieve Conjur secrets, plan privately, apply a reviewed artifact."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time
import urllib.request

import boto3
from botocore.config import Config
from conjur import Conjur, environment, resolve_inputs
from plans import digest, input_digest, require_trusted_event, summarize, validate_artifact, redact_review, require_no_new_drift, execution_digest, observed_credentials

ROOT = Path(__file__).resolve().parents[1]


def terraform(args, env, allowed=(0,)):
    process = subprocess.run([str(ROOT / '.ci-bin/terraform'), *args], cwd=ROOT,
                             env=env, capture_output=True)
    if process.returncode not in allowed:
        # Terraform diagnostics can include dynamic request configuration. Keep them private.
        (Path(env['TF_DATA_DIR']).parent / 'failure.log').write_bytes(process.stdout + process.stderr)
        raise RuntimeError('Terraform command failed; diagnostics retained in the private run artifact')
    return process.stdout, process.returncode


def git_commit():
    return subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()


def require_current_main(settings, commit):
    request = urllib.request.Request(
        settings['server_url'] + '/api/v1/repos/' + settings['repository'] + '/branches/main',
        headers={'Authorization': 'token ' + os.environ['CI_TOKEN']})
    with urllib.request.urlopen(request, timeout=30) as response:
        branch = json.load(response)
    if branch['commit']['id'] != commit:
        raise ValueError('Main has advanced; create and review a current main plan')


def check_state(env, settings):
    raw, _ = terraform(['state', 'pull'], env)
    state = json.loads(raw)
    count = sum(len(resource.get('instances', [])) for resource in state.get('resources', [])
                if resource['mode'] == 'managed')
    if count < settings['minimum_managed_resources']:
        raise ValueError('Canonical imported state is missing or incomplete; refusing to plan')
    return {'lineage': state['lineage'], 'serial': state['serial'], 'managed_resources': count}


def execute(mode, plan_id='', reviewed_sha='', noop_only=False):
    settings = json.loads((ROOT / 'ci/settings.json').read_text())
    event_name = os.environ['CI_EVENT_NAME']
    ref = os.environ['CI_REF']
    repository = os.environ['CI_REPOSITORY']
    event = json.loads(Path(os.environ['CI_EVENT_PATH']).read_text())
    require_trusted_event(settings, event_name, ref, repository, event, applying=mode == 'apply')
    commit = git_commit()
    if commit != os.environ['CI_SHA']:
        raise ValueError('Checkout does not match the workflow source commit')
    if mode == 'apply':
        require_current_main(settings, commit)
    run_id = os.environ['CI_RUN_ID'] + '-' + (os.environ.get('CI_RUN_ATTEMPT') or '1')
    if not re.fullmatch(r'[0-9]+-[0-9]+', run_id):
        raise ValueError('Invalid workflow run identifier')
    conjur = Conjur(settings)
    bindings = json.loads((ROOT / 'config/secret-bindings.json').read_text())
    inputs = resolve_inputs(json.loads((ROOT / 'config/desired.json').read_text()), bindings, conjur.get)
    # Temporary data includes cached backend metadata and plans; remove it after every run.
    with tempfile.TemporaryDirectory(prefix='vulture-tf-') as temporary:
        work = Path(temporary)
        env = environment(settings, inputs, conjur.get, work / 'data')
        env['TF_CLI_CONFIG_FILE'] = str(ROOT / 'ci/registry.tfrc')
        env['TF_WORKSPACE'] = 'default'
        s3 = boto3.client('s3', endpoint_url=settings['s3_endpoint'],
                          aws_access_key_id=env['AWS_ACCESS_KEY_ID'],
                          aws_secret_access_key=env['AWS_SECRET_ACCESS_KEY'],
                          region_name=settings['region'],
                          config=Config(signature_version='s3v4', s3={'addressing_style': 'path'},
                                        request_checksum_calculation='when_required'))
        bucket = settings['bucket']

        def put(key, body):
            s3.put_object(Bucket=bucket, Key=key, Body=body, IfNoneMatch='*')

        def get(key):
            return s3.get_object(Bucket=bucket, Key=key)['Body'].read()

        try:
            terraform(['init', '-input=false', '-lockfile=readonly', '-no-color'], env)
            terraform(['validate', '-no-color'], env)
            state = check_state(env, settings)
            plan = work / 'reviewed.tfplan'
            if mode == 'plan':
                output, code = terraform(['plan', '-input=false', '-no-color', '-lock-timeout=5m',
                                          '-parallelism=4', '-detailed-exitcode', '-out=' + str(plan)], env, (0, 2))
                raw, _ = terraform(['show', '-json', str(plan)], env)
                planned_json = json.loads(raw)
                summary = summarize(planned_json)
                manifest = {'schema_version': 1, 'repository': repository, 'ref': ref,
                            'event': event_name, 'commit': commit, 'run_id': run_id,
                            'created_at': time.time(), 'plan_sha256': digest(plan.read_bytes()),
                            'execution_sha256': execution_digest(inputs, env), 'state': state, 'summary': summary,
                            'terraform_plan_exit': code}
                prefix = 'plans/' + run_id + '/'
                put(prefix + 'reviewed.tfplan', plan.read_bytes())
                review, _ = terraform(['show', '-no-color', str(plan)], env)
                secret_values = [env[key] for key in ('PANW_MGMT_CLIENT_ID', 'PANW_MGMT_CLIENT_SECRET', 'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY')]
                for binding in bindings:
                    value = inputs
                    for key in binding['path']:
                        value = value[key]
                    secret_values.append(value)
                secret_values.extend(observed_credentials(planned_json, bindings))
                put(prefix + 'review.txt', redact_review(review.decode(), secret_values).encode())
                put(prefix + 'manifest.json', json.dumps(manifest, indent=2).encode())
                print(json.dumps({'plan_id': run_id, 'commit': commit, 'state': state,
                                  'plan_sha256': manifest['plan_sha256'], **summary}, indent=2))
                print('Review the private review.txt and Git diff before dispatching apply.')
            else:
                if not re.fullmatch(r'[0-9]+-[0-9]+', plan_id):
                    raise ValueError('Provide the reviewed plan ID shown by the plan run')
                prefix = 'plans/' + plan_id + '/'
                manifest = json.loads(get(prefix + 'manifest.json'))
                plan_bytes = get(prefix + 'reviewed.tfplan')
                summary = validate_artifact(manifest, plan_bytes, reviewed_sha, settings, commit, inputs, env)
                if state != manifest['state']:
                    raise ValueError('State changed since plan; create and review a new plan')
                plan.write_bytes(plan_bytes)
                raw, _ = terraform(['show', '-json', str(plan)], env)
                reviewed_plan = json.loads(raw)
                actual_summary = summarize(reviewed_plan)
                if actual_summary != summary:
                    raise ValueError('Artifact summary does not match the saved Terraform plan')
                if noop_only and not actual_summary['noop']:
                    raise ValueError('First cutover apply must be a no-op')
                drift_plan = work / 'drift.tfplan'
                terraform(['plan', '-refresh-only', '-input=false', '-no-color', '-lock-timeout=5m',
                           '-parallelism=4', '-detailed-exitcode', '-out=' + str(drift_plan)], env, (0, 2))
                drift_raw, _ = terraform(['show', '-json', str(drift_plan)], env)
                drift = json.loads(drift_raw)
                require_no_new_drift(reviewed_plan, drift)
                require_current_main(settings, commit)
                terraform(['apply', '-input=false', '-no-color', '-lock-timeout=5m', str(plan)], env)
                final_state = check_state(env, settings)
                result = {'plan_id': plan_id, 'commit': commit, 'applied': True,
                          'noop': actual_summary['noop'], 'state': final_state}
                put('plans/' + run_id + '/apply-result.json', json.dumps(result, indent=2).encode())
                print(json.dumps(result, indent=2))
        except Exception as error:
            try:
                put('plans/' + run_id + '/failure-result.json',
                    json.dumps({'error_type': type(error).__name__, 'reason': str(error),
                                'commit': commit}).encode())
            except Exception:
                pass
            failure = work / 'failure.log'
            if failure.exists():
                try:
                    put('plans/' + run_id + '/failure.log', failure.read_bytes())
                except Exception:
                    pass
            raise


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('mode', choices=['plan', 'apply'])
    parser.add_argument('--plan-id', default='')
    parser.add_argument('--reviewed-sha256', default='')
    parser.add_argument('--noop-only', action='store_true')
    args = parser.parse_args()
    try:
        execute(args.mode, args.plan_id, args.reviewed_sha256, args.noop_only)
    except Exception as error:
        print('CI operation refused or failed:', str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
