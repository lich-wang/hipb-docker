import http.server
import socketserver
import os

PORT = 8000
DIRECTORY = "responses"

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith("/range/"):
            prefix = self.path.split("/range/")[1].upper()
            filename = f"response_{prefix}.txt"
            filepath = os.path.join(DIRECTORY, filename)
            if os.path.exists(filepath):
                self.send_response(200)
                self.send_header("Content-type", "text/plain")
                self.end_headers()
                with open(filepath, "rb") as file:
                    self.wfile.write(file.read())
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b"Prefix not found")
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Invalid endpoint")

os.chdir(DIRECTORY)
handler = CustomHandler

with socketserver.TCPServer(("", PORT), handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
