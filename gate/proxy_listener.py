import os
import json
import urllib.request
from http.server import BaseHTTPRequestHandler, HTTPServer

HOST = os.getenv("GATE_HOST", "localhost")
PORT = int(os.getenv("GATE_PORT", 8080))
N8N_URL = os.getenv("N8N_PIPELINE_URL", "http://localhost:5678/webhook/etb-threats")
API_KEY = os.getenv("GATE_ENGINE_API_KEY", "EB-COMMAND-CENTER-SECURE-KEY")
DASHBOARD_PATH = r"C:\Users\casei\Desktop\etb_payshield\dashboard\active_threat_feed.json"

class ETBValidationGate(BaseHTTPRequestHandler):
    def do_POST(self):
        api_key_header = self.headers.get("X-ETB-Key")
        if not api_key_header or api_key_header != API_KEY:
            self.send_response(403)
            self.end_headers()
            self.wfile.write(b'{"error": "LayerZero Gate: Unauthorized Access Defended"}')
            return

        content_length = int(self.headers.get('Content-Length', 0))
        raw_body = self.rfile.read(content_length)
        try:
            payload = json.loads(raw_body.decode('utf-8'))
        except json.JSONDecodeError:
            self.send_response(400)
            self.end_headers()
            return

        # Direct localized write handle for instant dashboard availability
        try:
            with open(DASHBOARD_PATH, "w") as f:
                json.dump(payload, f, indent=4)
        except Exception as e:
            print(f"[-] Local file write error: {e}")

        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(b'{"status": "Verified", "gateway": "ETB LayerZero Gate Passed"}')

        try:
            req = urllib.request.Request(N8N_URL, data=json.dumps(payload).encode('utf-8'), headers={'Content-Type': 'application/json'})
            with urllib.request.urlopen(req, timeout=2) as response: pass
        except Exception: pass

if __name__ == "__main__":
    print(f"[*] ETB PayShield LayerZero Gate running on http://{HOST}:{PORT}")
    server = HTTPServer((HOST, PORT), ETBValidationGate)
    server.serve_forever()
