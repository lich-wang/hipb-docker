# 使用官方的Python基础镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 复制应用代码
COPY . /app

# 安装Python依赖包
RUN pip install --no-cache-dir fastapi uvicorn requests

# 暴露服务端口
EXPOSE 8000

# 启动FastAPI应用
CMD ["uvicorn", "service:app", "--host", "0.0.0.0", "--port", "8000"]
