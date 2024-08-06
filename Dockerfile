# 使用官方的Python基础镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 复制下载脚本和服务脚本到工作目录
COPY pwned_passwords_downloader.py service.py ./

# 安装所需的Python包
RUN pip install requests

# 运行下载脚本以下载文件
RUN python pwned_passwords_downloader.py

# 暴露服务端口
EXPOSE 8000

# 启动HTTP服务
CMD ["python", "service.py"]


#sudo docker pull lichwang/pwnedpasswords
#sudo docker run -d -p 8000:8000 lichwang/pwnedpasswords