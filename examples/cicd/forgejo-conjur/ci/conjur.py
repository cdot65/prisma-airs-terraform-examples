"""Retrieve workload secrets without putting them in workflow outputs or files."""
import base64
import copy
import json
import os
from pathlib import Path
import ssl
import urllib.error
import urllib.parse
import urllib.request


class Conjur:
    def __init__(self, settings, token_path='/conjur/token', ca_path='/conjur/ca.pem'):
        self.base = settings['conjur_url'].rstrip('/')
        self.account = settings['conjur_account']
        self.context = ssl.create_default_context(cafile=ca_path)
        service = urllib.parse.quote(settings['conjur_service_id'], safe='')
        body = urllib.parse.urlencode({'jwt': Path(token_path).read_text().strip()}).encode()
        raw = self.request('POST', f'/authn-jwt/{service}/{self.account}/authenticate', body,
                           content_type='application/x-www-form-urlencoded')
        self.token = base64.b64encode(raw).decode()

    def request(self, method, path, body=None, content_type='application/octet-stream'):
        headers = {'Content-Type': content_type}
        if hasattr(self, 'token'):
            headers['Authorization'] = f'Token token="{self.token}"'
        request = urllib.request.Request(self.base + path, data=body, headers=headers, method=method)
        try:
            with urllib.request.urlopen(request, context=self.context, timeout=30) as response:
                return response.read()
        except urllib.error.HTTPError as error:
            raise RuntimeError(f'Conjur request failed (HTTP {error.code}); response withheld') from None

    def get(self, variable):
        return self.request('GET', f'/secrets/{self.account}/variable/' +
                            urllib.parse.quote(variable, safe='')).decode()


def resolve_inputs(desired, bindings, get_secret):
    """Replace only declared null leaves; retain every other input exactly."""
    result = copy.deepcopy(desired)
    seen = set()
    for binding in bindings:
        path = binding['path']
        if not path or not all(isinstance(key, str) for key in path):
            raise ValueError('Secret binding paths must contain object keys')
        if tuple(path) in seen:
            raise ValueError('Duplicate secret binding path')
        seen.add(tuple(path))
        cursor = result
        for key in path[:-1]:
            cursor = cursor[key]
        if path[-1] not in cursor or cursor[path[-1]] is not None:
            raise ValueError('Secret binding must replace an existing null placeholder')
        value = get_secret(binding['variable'])
        if not value:
            raise ValueError('A bound Conjur credential is empty')
        cursor[path[-1]] = value
    return result


def environment(settings, inputs, get_secret, data_dir):
    # Authentication: Discard ambient Terraform/provider overrides before binding Vulture.
    env = {key: value for key, value in os.environ.items()
           if not key.startswith(('PANW_', 'AWS_', 'TF_'))}
    prefix = settings['conjur_prefix']
    for name, leaf in [('PANW_MGMT_CLIENT_ID', 'management/client-id'),
                       ('PANW_MGMT_CLIENT_SECRET', 'management/client-secret'),
                       ('PANW_MGMT_TSG_ID', 'management/tsg-id'),
                       ('AWS_ACCESS_KEY_ID', 'backend/access-key-id'),
                       ('AWS_SECRET_ACCESS_KEY', 'backend/secret-access-key')]:
        env[name] = get_secret(prefix + '/' + leaf)
        if not env[name]:
            raise ValueError('A required Conjur credential is empty')
    if env['PANW_MGMT_TSG_ID'] != settings['expected_tsg_id']:
        raise ValueError('Management credentials target a different tenant')
    for name, value in inputs.items():
        env['TF_VAR_' + name] = json.dumps(value, separators=(',', ':'))
    env.update(TF_IN_AUTOMATION='1', TF_INPUT='0', TF_DATA_DIR=str(data_dir),
               AWS_ENDPOINT_URL_S3=settings['s3_endpoint'], AWS_DEFAULT_REGION=settings['region'],
               AWS_EC2_METADATA_DISABLED='true')
    return env
