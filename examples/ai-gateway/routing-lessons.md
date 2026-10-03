# Routing and policy lessons

Start with the [application guide](README.md) and confirm that a benign request succeeds. These exercises change only the example's owned configuration. Keep a healthy secondary connection and retain the original inputs and credentials so you can restore them afterward.

## Observe target selection

The response header `x-portkey-last-used-option-index` reports paths such as `config.targets[0]` and `config.targets[1]`. The request helper prints that path. Conditional requests with `--tier standard` and `--tier premium` should select different targets. A weighted sample should reach both targets, but any short random sample can differ from the configured percentage.

The live routing demonstration used two owned connections to one MLX backend. It established connection selection and controlled failover; it did not establish independent-service availability. You can use different model services through `secondary_upstream` when both are supported by your Gateway runtime.

## Force a fallback safely

A healthy primary alone does not exercise fallback. For a repeatable demonstration using a credential-authenticated test service:

1. Confirm that each owned connection succeeds with its real credential.
2. Temporarily set `retry_attempts = 0` and add `401` to `fallback_status_codes` in your nonsecret input file.
3. Through your credential store/environment, replace only the **owned primary integration's** desired key with a deliberately invalid test value. Keep the secondary key valid.
4. Review and apply the plan. Wait for data-plane propagation.
5. Run `python3 demo.py --mode fallback`. A successful response with `target=config.targets[1]` demonstrates that the failed primary advanced to the healthy secondary.
6. Restore the original primary credential, retry count, and fallback codes, then review and apply the restoration plan.

This exercise requires an upstream that returns HTTP 401 for that fault. The normal example defaults to 429 and common server errors; adding 401 is an explicit teaching fixture. Keep retry counts low while testing to bound replayed requests.

## Observe request and token policies

The policies match `metadata.application`, which is present in both application-key defaults and the helper's request headers. Their aggregation covers this application's routing keys.

To explore rate enforcement, temporarily lower `requests_per_minute` and apply it. Send bounded requests, inspect a rate-limit rejection in Gateway logs, then restore the original threshold. Account for the current rolling window; existing requests can make the first new request exceed the lowered threshold.

To explore token enforcement, temporarily lower `token_budget` below the application's accumulated usage and apply it. A usage-limit rejection should appear in Gateway logs. Restore the original budget afterward. Terraform changes the threshold but does not reset accumulated credits.

A generic HTTP 429 by itself does not distinguish an application policy from an upstream limit. Verify the corresponding policy error or Gateway log entry. See [run evidence](../../docs/live-runs/ai-gateway-expanded.md) for the exact observed outcomes.

## Observe caching

Run `python3 demo.py --mode cached --repeat 2`. Repeat the identical request within `cache_max_age`: the first response should be a MISS and the next a HIT when the deployment has cache support. The config uses a single root provider and a simple cache; it does not claim semantic caching.

Caching is a data-plane capability. If requests fail or cache status remains unreported, inspect the deployment and its cache configuration rather than accepting the Terraform apply as proof of a cache hit.
