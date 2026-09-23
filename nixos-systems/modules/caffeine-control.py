"""Caffeine control service for the llm-proxy keep-awake hooks.

Runs inside the graphical session so `noctalia msg` can reach the daemon.
The proxy's keep-awake hooks (llm-proxy scripts/caffeine-{enable,disable}.sh)
curl these endpoints.

Endpoints (GET):
  /caffeine/enable   -> noctalia msg caffeine-enable   -> "caffeinate enabled"
  /caffeine/disable  -> noctalia msg caffeine-disable  -> "caffeinate disabled"

The message is echoed in the response body and on stdout (so it shows up in
`journalctl --user -u caffeine-control`); the hooks only look at the status
code, not the body.

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

# What to run for each endpoint, and what to report once it worked.
CMDS = {
    "/caffeine/enable": (
        ["noctalia", "msg", "caffeine-enable"],
        "caffeinate enabled",
    ),
    "/caffeine/disable": (
        ["noctalia", "msg", "caffeine-disable"],
        "caffeinate disabled",
    ),
}


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if TOKEN and self.headers.get("Authorization") != f"Bearer {TOKEN}":
            self.send_error(401)
            return
        entry = CMDS.get(self.path)
        if entry is None:
            self.send_error(404)
            return
        cmd, message = entry
        try:
            subprocess.run(cmd, check=True, timeout=10)
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
            self.send_error(500, str(e))
            return
        print(message, flush=True)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(f"{message}\n".encode())

    def log_message(self, *_args):
        pass


if __name__ == "__main__":
    http.server.ThreadingHTTPServer((ADDR, PORT), Handler).serve_forever()
