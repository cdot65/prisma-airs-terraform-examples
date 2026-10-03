"""Credential transport and negative-probe checks; no tenant access or real keys."""
import contextlib
import importlib.util
import io
import os
from pathlib import Path
import sys
import threading
import unittest
from unittest import mock
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('gateway_demo', ROOT / 'examples/ai-gateway/demo.py')
demo = importlib.util.module_from_spec(spec)
spec.loader.exec_module(demo)


class DenialTests(unittest.TestCase):
    def run_probe(self, payload, status=446, attack=False):
        values = {'application_keys': {'fallback': 'unit-test-credential'},
                  'application_metadata': {'application': 'unit-test'}, 'request_model': '@unit/model',
                  'guardrail_slugs': {'marker': 'pg-owned-marker', 'airs': 'pg-owned-airs'}}
        with mock.patch.object(sys, 'argv', ['demo.py', '--attack' if attack else '--deny']), \
             mock.patch.dict(os.environ, {'PANW_AI_GW_INFERENCE_ENDPOINT': 'https://gateway.invalid/v1'}), \
             mock.patch.object(demo, 'output', side_effect=lambda name: values[name]), \
             mock.patch.object(demo, 'request', return_value=(status, payload, {})), \
             contextlib.redirect_stdout(io.StringIO()) as console:
            demo.main()
        self.assertNotIn('unit-test-credential', console.getvalue())
        return console.getvalue()

    def test_auth_error_mentioning_guardrails_is_not_a_denial(self):
        with self.assertRaises(SystemExit):
            self.run_probe({'error': {'message': 'guardrail authentication failed'}}, status=401)

    def test_another_failed_check_is_not_the_marker_demonstration(self):
        with self.assertRaises(SystemExit):
            self.run_probe({'hook_results': {'before_request_hooks': [
                {'id': 'pg-owned-marker', 'checks': [{'id': 'other.check', 'verdict': False}]}]}})

    def test_matching_check_in_another_guardrail_does_not_count(self):
        with self.assertRaises(SystemExit):
            self.run_probe({'hook_results': {'before_request_hooks': [
                {'id': 'pg-unrelated', 'checks': [{'id': 'default.contains', 'verdict': False}]}]}})

    def test_marker_requires_its_own_failed_verdict(self):
        self.assertIn('default.contains denied probe', self.run_probe({'hook_results': {
            'before_request_hooks': [{'id': 'pg-owned-marker', 'checks': [{'id': 'default.contains', 'verdict': False}]}]}}))

    def test_scanner_error_is_not_injection_detection(self):
        with self.assertRaises(SystemExit):
            self.run_probe({'hook_results': {'before_request_hooks': [{'id': 'pg-owned-airs', 'checks': [{
                'id': 'panw-prisma-airs.intercept', 'verdict': False,
                'data': {'error': True, 'action': 'block', 'prompt_detected': {'injection': True}},
            }]}]}}, attack=True)

    def test_injection_block_requires_detection_and_no_scanner_error(self):
        self.assertIn('panw-prisma-airs.intercept denied probe', self.run_probe({'hook_results': {
            'before_request_hooks': [{'id': 'pg-owned-airs', 'checks': [{
                'id': 'panw-prisma-airs.intercept', 'verdict': False,
                'data': {'error': False, 'action': 'block', 'prompt_detected': {'injection': True}},
            }]}]}}, attack=True))


class TransportTests(unittest.TestCase):
    def test_redirect_does_not_forward_the_application_credential(self):
        received = []

        class Receiver(BaseHTTPRequestHandler):
            def do_GET(self):
                received.append(dict(self.headers))
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b'{}')
            do_POST = do_GET
            def log_message(self, *args):
                pass

        receiver = ThreadingHTTPServer(('127.0.0.1', 0), Receiver)
        destination = f'http://127.0.0.1:{receiver.server_port}/capture'

        class Redirect(BaseHTTPRequestHandler):
            def do_POST(self):
                self.send_response(307)
                self.send_header('Location', destination)
                self.end_headers()
            def log_message(self, *args):
                pass

        redirect = ThreadingHTTPServer(('127.0.0.1', 0), Redirect)
        for server in (receiver, redirect):
            threading.Thread(target=server.serve_forever, daemon=True).start()
        try:
            # Loopback HTTP fixture exercises transport; the CLI requires HTTPS.
            status, _, _ = demo.request(f'http://127.0.0.1:{redirect.server_port}',
                                        'unit-test-credential', '@unit/model', {}, 'Hello')
            self.assertEqual(status, 307)
            self.assertEqual(received, [])
        finally:
            for server in (receiver, redirect):
                server.shutdown()
                server.server_close()


if __name__ == '__main__':
    unittest.main()
