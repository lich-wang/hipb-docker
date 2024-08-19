import os
import requests
from datetime import datetime, timedelta
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse

# FastAPI 应用
app = FastAPI()

# 文件存储目录
RESPONSE_DIR = "/app/responses"  # 本地缓存目录
EXPIRATION_TIME = timedelta(days=1)  # 文件有效期为1天

# 创建响应目录
if not os.path.exists(RESPONSE_DIR):
    os.makedirs(RESPONSE_DIR)

# 从 Pwned Passwords API 获取数据
def fetch_from_api(hash_prefix):
    url = f"https://api.pwnedpasswords.com/range/{hash_prefix.upper()}"
    response = requests.get(url)
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail="Error fetching data from API")
    return response.text

# 检查本地文件是否过期
def is_file_expired(file_path):
    if not os.path.exists(file_path):
        return True
    file_mod_time = datetime.fromtimestamp(os.path.getmtime(file_path))
    if datetime.now() - file_mod_time > EXPIRATION_TIME:
        return True
    return False

@app.get("/")
async def read_root():
    return FileResponse('index.html')

# 处理请求并返回数据
@app.get("/range/{prefix}")
async def handle(prefix: str):
    prefix = prefix.lower()
    file_path = os.path.join(RESPONSE_DIR, f"response_{prefix}.txt")
    
    if is_file_expired(file_path):
        try:
            # 文件不存在或已过期，重新从API获取数据并保存
            data = fetch_from_api(prefix)
            with open(file_path, 'w') as file:
                file.write(data)
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    # 返回本地文件内容
    return FileResponse(file_path)

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
