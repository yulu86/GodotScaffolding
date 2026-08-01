"""HTTPS server for Godot Web exports with required Cross-Origin headers.

Serves the project's build/ directory over https on port 8443 with a self-signed cert.
Auto-detects the project root by walking up from this script's location until it finds
project.godot, then serves <project_root>/build/.

Usage:
    python <skill>/scripts/https_server.py

Requires cert.pem and key.pem. Auto-detected in priority:
    1. HTTPS_CERT_DIR env var
    2. this script's directory
    3. <project_root>/.tmp/

Generate once (Git Bash on Windows needs MSYS_NO_PATHCONV=1):
    MSYS_NO_PATHCONV=1 openssl req -x509 -newkey rsa:2048 -nodes \
        -keyout .tmp/key.pem -out .tmp/cert.pem -days 365 -subj "/CN=localhost"

Design note: directory is set as a class attribute on Handler (not an __init__ kwarg),
because passing a lambda/closure to ThreadingHTTPServer has been observed to cause
chrome to report ERR_INVALID_HTTP_RESPONSE (TLS renegotiation / HTTP framing issue).
The class-attribute approach is the simplest form that reliably works.
"""
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import ssl
import os
import sys

PORT = 8443


def find_project_root() -> str:
    """Walk up from this script until project.godot is found."""
    d = os.path.dirname(os.path.abspath(__file__))
    for _ in range(10):
        if os.path.exists(os.path.join(d, "project.godot")):
            return d
        parent = os.path.dirname(d)
        if parent == d:
            break
        d = parent
    return os.getcwd()


def find_build_dir(project_root: str) -> str:
    build = os.path.join(project_root, "build")
    if not os.path.isdir(build):
        raise SystemExit(f"[https] build/ not found at {build}. Run web export first.")
    return build


def find_cert_dir() -> str:
    env_dir = os.environ.get("HTTPS_CERT_DIR")
    if env_dir and os.path.exists(os.path.join(env_dir, "cert.pem")):
        return env_dir
    script_dir = os.path.dirname(os.path.abspath(__file__))
    if os.path.exists(os.path.join(script_dir, "cert.pem")):
        return script_dir
    project_root = find_project_root()
    tmp_dir = os.path.join(project_root, ".tmp")
    if os.path.exists(os.path.join(tmp_dir, "cert.pem")):
        return tmp_dir
    raise SystemExit(
        "[https] cert.pem/key.pem not found. Generate with:\n"
        "  MSYS_NO_PATHCONV=1 openssl req -x509 -newkey rsa:2048 -nodes "
        "-keyout .tmp/key.pem -out .tmp/cert.pem -days 365 -subj \"/CN=localhost\""
    )


class Handler(SimpleHTTPRequestHandler):
    """Serves build/ with Godot web's required COOP/COEP/CORP headers.

    `serve_dir` is a class attribute set in main() before the server starts.
    """

    serve_dir: str = "."

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=Handler.serve_dir, **kwargs)

    def end_headers(self):
        # Godot 4 web (SharedArrayBuffer) requires these three headers.
        # Missing any => "Cross-Origin Isolation - missing" error in console.
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Resource-Policy", "same-origin")
        super().end_headers()


def main():
    project_root = find_project_root()
    build_dir = find_build_dir(project_root)
    cert_dir = find_cert_dir()

    # Set class attribute BEFORE creating the server so Handler.__init__ picks it up.
    Handler.serve_dir = build_dir

    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(
        certfile=os.path.join(cert_dir, "cert.pem"),
        keyfile=os.path.join(cert_dir, "key.pem"),
    )

    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    server.socket = context.wrap_socket(server.socket, server_side=True)
    print(f"[https] serving {build_dir} on https://localhost:{PORT}")
    print(f"[https] cert from {cert_dir}")
    sys.stdout.flush()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("[https] shutting down")
        server.shutdown()


if __name__ == "__main__":
    main()
