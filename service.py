import os
from aiohttp import web

DIRECTORY = "/app/responses"  # 确保此目录存在

async def handle(request):
    path = request.match_info.get('prefix', "").lower()
    filename = f"response_{path}.txt"
    filepath = os.path.join(DIRECTORY, filename)
    print(f"Looking for file: {filepath}")
    if os.path.exists(filepath):
        print(f"Found file: {filepath}")
        return web.FileResponse(filepath)
    else:
        print(f"File not found: {filepath}")
        return web.Response(text="Prefix not found", status=404)

app = web.Application()
app.router.add_get('/range/{prefix}', handle)

if __name__ == '__main__':
    web.run_app(app, port=8000)
