#!/bin/bash

# 定义日志文件
LOG_FILE="deploy.log"
exec > >(tee -i $LOG_FILE)
exec 2>&1

# 远端服务器信息
REMOTE_SERVER="root@49.234.185.20"
REMOTE_DIR="/root/pwnedpasswords"

# 基础镜像和依赖包名称
IMAGE_NAME="python:3.10-slim"
IMAGE_TAR="python-3.10-slim.tar"
DEPENDENCIES_TAR="pwnedpasswords-dependencies.tar.gz"

# 清理远程服务器上的空间
echo "Cleaning up space on remote server..."
ssh $REMOTE_SERVER << EOF
  set -e
  docker system prune -f
  docker volume prune -f
  rm -rf $REMOTE_DIR
EOF

if [ $? -ne 0 ]; then
  echo "Failed to clean up space on remote server. Exiting."
  exit 1
fi

# 确保Docker镜像已被拉取
echo "Pulling Docker image..."
sudo docker pull $IMAGE_NAME

# 保存基础镜像为tar文件
echo "Saving Docker image to tar file..."
sudo docker save -o $IMAGE_TAR $IMAGE_NAME

# 检查是否保存成功
if [ $? -ne 0 ]; then
  echo "Failed to save Docker image. Exiting."
  exit 1
fi

# 下载依赖包
echo "Downloading dependencies..."
mkdir -p dependencies
pip download -d dependencies aiohttp requests fastapi uvicorn

# 打包依赖包和脚本
echo "Creating tarball of dependencies and scripts..."
sudo tar czvf $DEPENDENCIES_TAR dependencies pwned_passwords_downloader.py service.py Dockerfile.remote $IMAGE_TAR

# 检查是否打包成功
if [ $? -ne 0 ]; then
  echo "Failed to create tarball. Exiting."
  exit 1
fi

# 传输文件到远端服务器
echo "Transferring files to remote server..."
scp $DEPENDENCIES_TAR $REMOTE_SERVER:/root

# 检查是否传输成功
if [ $? -ne 0 ]; then
  echo "Failed to transfer files to remote server. Exiting."
  exit 1
fi

# 在远端服务器上解压、加载镜像并构建Docker容器
echo "Connecting to remote server and setting up Docker container..."
ssh $REMOTE_SERVER << EOF
  set -e
  mkdir -p $REMOTE_DIR
  tar xzvf /root/$DEPENDENCIES_TAR -C $REMOTE_DIR
  cd $REMOTE_DIR
  sudo docker load -i $IMAGE_TAR
  sudo docker build -f Dockerfile.remote -t pwnedpasswords-service .

  # 使用 nohup 运行耗时的下载脚本，确保不会因SSH断开而中止
  nohup sudo docker run -d -p 8000:8000 pwnedpasswords-service > pwnedpasswords-service.log 2>&1 &
EOF

if [ $? -ne 0 ]; then
  echo "Failed to set up Docker container on remote server. Exiting."
  exit 1
fi

# 清理临时文件
echo "Cleaning up..."
rm -rf dependencies $IMAGE_TAR $DEPENDENCIES_TAR

echo "Deployment completed successfully."
