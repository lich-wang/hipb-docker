import http.server
import socketserver
import os

PORT = 8000
DIRECTORY = "/app/responses"  # 使用绝对路径

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith("/range/"):
            prefix = self.path.split("/range/")[1].lower()  # 转换为小写
            filename = f"response_{prefix}.txt"
            filepath = os.path.join(DIRECTORY, filename)
            print(f"Looking for file: {filepath}")
            if os.path.exists(filepath):
                print(f"Found file: {filepath}")
                self.send_response(200)
                self.send_header("Content-type", "text/plain")
                self.end_headers()
                with open(filepath, "rb") as file:
                    self.wfile.write(file.read())
            else:
                print(f"File not found: {filepath}")
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b"Prefix not found")
        else:
            print(f"Invalid endpoint: {self.path}")
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Invalid endpoint")

print(f"Changing directory to: {DIRECTORY}")
os.chdir(DIRECTORY)
handler = CustomHandler

with socketserver.TCPServer(("", PORT), handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
