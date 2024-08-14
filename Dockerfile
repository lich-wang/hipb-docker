# 使用官方的Python基础镜像
FROM python:3.10-slim AS builder

# 设置工作目录
WORKDIR /app

# 复制下载脚本和服务脚本到工作目录
COPY pwned_passwords_downloader.py service.py ./

# 安装所需的Python包
RUN --network=host pip install aiohttp requests fastapi uvicorn

# 运行下载脚本以下载文件，默认下载所有
ARG LIMIT=1000
RUN python pwned_passwords_downloader.py $LIMIT

# 使用一个更小的基础镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 复制从构建阶段生成的文件
COPY --from=builder /app /app

# 再次安装所需的Python包
RUN --network=host pip install fastapi uvicorn

# 暴露服务端口
EXPOSE 8000

# 启动HTTP服务
CMD ["uvicorn", "service:app", "--host", "0.0.0.0", "--port", "8000"]
