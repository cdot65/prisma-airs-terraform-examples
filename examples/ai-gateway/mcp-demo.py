#!/usr/bin/env python3
"""Initialize an owned MCP server, list tools, and optionally invoke one explicit tool."""
import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from demo import NoRedirect, output


def decode(raw):
    text = raw.decode('utf-8-sig')
    if text.lstrip().startswith('{'):
        return json.loads(text)
    data = []
    # SSE dispatches at a blank line, joining data fields with newlines.
    # Normalize only SSE line endings; discard an unfinished event at EOF.
    for line in text.replace('\r\n', '\n').replace('\r', '\n').split('\n')[:-1]:
        if not line:
            payload = '\n'.join(data)
            data = []
            if payload:
                value = json.loads(payload)
                if isinstance(value, dict) and ('result' in value or 'error' in value):
                    return value
        else:
            field, _, value = line.partition(':')
            if field == 'data':
                data.append(value.removeprefix(' '))
    return {}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--tool', help='Optional tool name; no invocation occurs unless supplied.')
    parser.add_argument('--arguments', default='{}', help='JSON object for the selected tool.')
    args = parser.parse_args()
    slug = output('mcp_server_slug')
    if not slug:
        sys.exit('Enable MCP and apply the project first.')
    template = os.environ.get('PANW_AI_GW_MCP_ENDPOINT', '')
    if '{server_slug}' not in template:
        sys.exit('Set PANW_AI_GW_MCP_ENDPOINT to your Gateway MCP URL containing {server_slug}.')
    endpoint = template.replace('{server_slug}', urllib.parse.quote(slug, safe=''))
    parsed = urllib.parse.urlsplit(endpoint)
    if parsed.scheme != 'https' or not parsed.hostname or parsed.username or parsed.password or parsed.query or parsed.fragment:
        sys.exit('The MCP endpoint must use HTTPS without URL credentials, query or fragment.')
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json, text/event-stream',
               'x-portkey-api-key': output('application_keys')['fallback']}
    opener = urllib.request.build_opener(NoRedirect)
    session = None

    def send(method, params=None, identifier=None):
        body = {'jsonrpc': '2.0', 'method': method}
        if params is not None:
            body['params'] = params
        if identifier is not None:
            body['id'] = identifier
        req = urllib.request.Request(endpoint, data=json.dumps(body).encode(), headers=headers)
        with opener.open(req, timeout=30) as response:
            session_header = response.headers.get('Mcp-Session-Id')
            raw = response.read(4 * 1024 * 1024)
        return decode(raw) if raw else {}, session_header

    try:
        initialized, session = send('initialize', {
            'protocolVersion': '2025-03-26', 'capabilities': {},
            'clientInfo': {'name': 'prisma-airs-terraform-example', 'version': '1.0'},
        }, 1)
        result = initialized.get('result', {})
        if not result.get('protocolVersion') or 'error' in initialized:
            sys.exit('MCP initialization failed. Check deployment connectivity and access.')
        if session:
            headers['Mcp-Session-Id'] = session
        headers['MCP-Protocol-Version'] = result['protocolVersion']
        send('notifications/initialized')
        listed, _ = send('tools/list', {}, 2)
        if 'error' in listed or not isinstance(listed.get('result', {}).get('tools'), list):
            sys.exit('MCP tool discovery failed. Check capability discovery and workspace access.')
        tools = listed['result']['tools']
        print(f'MCP initialized; {len(tools)} tools on the first page.')
        if args.tool:
            if args.tool not in [tool.get('name') for tool in tools]:
                sys.exit('Selected tool was not on the first page. Check its name and access settings.')
            arguments = json.loads(args.arguments)
            if not isinstance(arguments, dict):
                sys.exit('--arguments must be a JSON object.')
            called, _ = send('tools/call', {'name': args.tool, 'arguments': arguments}, 3)
            if 'error' in called or called.get('result', {}).get('isError') or 'content' not in called.get('result', {}):
                sys.exit('MCP tool invocation failed. Check tool permissions and arguments.')
            print('MCP tool invocation succeeded.')
    finally:
        if session:
            try:
                with opener.open(urllib.request.Request(endpoint, method='DELETE', headers=headers), timeout=15):
                    pass
            except urllib.error.HTTPError as error:
                if error.code not in (404, 405):
                    print('Session cleanup was not confirmed; check Gateway connections.', file=sys.stderr)
            except OSError:
                print('Session cleanup was not confirmed; check Gateway connections.', file=sys.stderr)


if __name__ == '__main__':
    try:
        main()
    except (ValueError, KeyError, OSError, RuntimeError, urllib.error.URLError):
        sys.exit('MCP request failed. Check environment, state, connectivity and Gateway logs.')
