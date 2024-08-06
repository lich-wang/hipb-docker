# 使用官方的Python基础镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 复制下载脚本、服务脚本和离线包到工作目录
COPY pwned_passwords_downloader.py service.py ./
COPY requests-*.whl ./

# 安装离线包
RUN pip install requests-*.whl

# 运行下载脚本以下载文件
RUN python pwned_passwords_downloader.py

# 暴露服务端口
EXPOSE 8000

# 启动HTTP服务
CMD ["python", "service.py"]
