"""Caffeine control service for the llm-proxy keep-awake hooks.

Runs inside the graphical session so `noctalia msg` can reach the daemon.
The proxy's keep-awake hooks (llm-proxy scripts/caffeine-{enable,disable}.sh)
curl these endpoints.

Endpoints (GET):
  /caffeine/enable   -> noctalia msg caffeine-enable
  /caffeine/disable  -> noctalia msg caffeine-disable

Env: CAFFEINE_ADDR (default 0.0.0.0), CAFFEINE_PORT (default 8765),
CAFFEINE_TOKEN (optional bearer token). Packaged and started as a systemd
user service by nixos-systems/modules/caffeine-control.nix.
"""
import http.server
import os
import subprocess

ADDR = os.environ.get("CAFFEINE_ADDR", "0.0.0.0")
PORT = int(os.environ.get("CAFFEINE_PORT", "8765"))
TOKEN = os.environ.get("CAFFEINE_TOKEN", "")

CMDS = {
    "/caffeine/enable": ["noctalia", "msg", "caffeine-enable"],
    "/caffeine/disable": ["noctalia", "msg", "caffeine-disable"],
}


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if TOKEN and self.headers.get("Authorization") != f"Bearer {TOKEN}":
            self.send_error(401)
            return
        cmd = CMDS.get(self.path)
        if cmd is None:
            self.send_error(404)
            return
        try:
            subprocess.run(cmd, check=True, timeout=10)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"ok")
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
            self.send_error(500, str(e))

    def log_message(self, *_args):
        pass


if __name__ == "__main__":
    http.server.ThreadingHTTPServer((ADDR, PORT), Handler).serve_forever()
