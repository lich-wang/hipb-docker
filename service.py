import os
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse

app = FastAPI()

DIRECTORY = "/app/responses"  # 确保此目录存在

@app.get("/range/{prefix}")
async def handle(prefix: str):
    prefix = prefix.lower()
    filename = f"response_{prefix}.txt"
    filepath = os.path.join(DIRECTORY, filename)
    print(f"Looking for file: {filepath}")
    if os.path.exists(filepath):
        print(f"Found file: {filepath}")
        return FileResponse(filepath)
    else:
        print(f"File not found: {filepath}")
        raise HTTPException(status_code=404, detail="Prefix not found")

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
