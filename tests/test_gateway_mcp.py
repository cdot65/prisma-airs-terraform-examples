"""Offline MCP response fixtures; no tenant access or credentials."""
import importlib.util
import json
from pathlib import Path
import sys
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('gateway_demo', ROOT / 'examples/ai-gateway/demo.py')
demo = importlib.util.module_from_spec(spec)
spec.loader.exec_module(demo)
spec = importlib.util.spec_from_file_location('gateway_mcp', ROOT / 'examples/ai-gateway/mcp-demo.py')
mcp = importlib.util.module_from_spec(spec)
with mock.patch.dict(sys.modules, {'demo': demo}):
    spec.loader.exec_module(mcp)


class ResponseTests(unittest.TestCase):
    def test_multiline_events_for_initialization_discovery_and_invocation(self):
        for result in [{'protocolVersion': '2025-03-26'}, {'tools': []}, {'content': []}]:
            expected = {'jsonrpc': '2.0', 'id': 1, 'result': result}
            for newline in ['\n', '\r\n', '\r']:
                with self.subTest(result=result, newline=repr(newline)):
                    # An empty data field is part of the event, not its boundary.
                    lines = [': heartbeat', 'event: message', 'id: example',
                             'data: {"jsonrpc": "2.0", "id": 1,', 'data',
                             'data: "result": ' + json.dumps(result) + '}', '', '']
                    raw = ('\ufeff' + newline.join(lines)).encode('utf-8')
                    self.assertEqual(mcp.decode(raw), expected)

    def test_plain_json_responses_remain_supported(self):
        for response in [{'result': {'tools': []}}, {'error': {'code': -32600}}]:
            with self.subTest(response=response):
                self.assertEqual(mcp.decode(json.dumps(response).encode()), response)

    def test_single_line_sse_error_response(self):
        raw = b'data:{"jsonrpc":"2.0","id":1,"error":{"code":-32600}}\n\n'
        self.assertEqual(mcp.decode(raw)['error'], {'code': -32600})

    def test_event_boundaries_separate_notifications_from_response(self):
        raw = (b': keepalive\n\n'
               b'data: {"jsonrpc":"2.0","method":"notifications/progress"}\n\n'
               b'event: message\ndata: {"jsonrpc":"2.0",\n'
               b'data: "id":1,"result":{"tools":[]}}\n\n')
        self.assertEqual(mcp.decode(raw), {'jsonrpc': '2.0', 'id': 1, 'result': {'tools': []}})

    def test_unterminated_event_is_not_dispatched(self):
        for ending in [b'', b'\n']:
            with self.subTest(ending=ending):
                self.assertEqual(mcp.decode(b'data: {"result":{"tools":[]}}' + ending), {})

    def test_malformed_complete_event_fails(self):
        with self.assertRaises(json.JSONDecodeError):
            mcp.decode(b'data: {invalid JSON}\n\n')


if __name__ == '__main__':
    unittest.main()
