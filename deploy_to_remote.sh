#!/bin/bash

# 定义日志文件
LOG_FILE="deploy.log"
exec > >(tee -i $LOG_FILE)
exec 2>&1

# 远端服务器信息
REMOTE_SERVER="root@49.234.185.20"
REMOTE_DIR="/root/pwnedpasswords"

# 镜像和tar文件
IMAGE_NAME="pwnedpasswords:live"
IMAGE_TAR="pwnedpasswords_live.tar"

# 端口
PORT=8000

# 清理远程服务器上的空间
echo "Cleaning up space on remote server..."
ssh $REMOTE_SERVER << EOF
  set -e
  docker stop pwnedpasswords_service || true
  docker rm pwnedpasswords_service || true
  docker system prune -f
  docker volume prune -f
  rm -rf $REMOTE_DIR
  fuser -k $PORT/tcp || true
EOF

if [ $? -ne 0 ]; then
  echo "Failed to clean up space on remote server. Exiting."
  exit 1
fi

# 保存本地Docker镜像为tar文件
echo "Saving Docker image to tar file..."
sudo docker save -o $IMAGE_TAR $IMAGE_NAME

# 修改文件权限，以确保用户能够传输文件
sudo chmod 644 $IMAGE_TAR

# 传输Docker镜像到远端服务器
echo "Transferring Docker image to remote server..."
scp $IMAGE_TAR $REMOTE_SERVER:/root

if [ $? -ne 0 ]; then
  echo "Failed to transfer Docker image. Exiting."
  exit 1
fi

# 在远端服务器上加载镜像并运行容器
echo "Connecting to remote server and setting up Docker container..."
ssh $REMOTE_SERVER << EOF
  set -e
  mkdir -p $REMOTE_DIR
  docker load -i /root/$IMAGE_TAR
  docker volume create pwnedpasswords_responses
  docker stop pwnedpasswords_service || true
  docker rm pwnedpasswords_service || true
  docker run -d --name pwnedpasswords_service -p $PORT:8000 -v pwnedpasswords_responses:/app/responses pwnedpasswords:live
EOF

if [ $? -ne 0 ]; then
  echo "Failed to set up Docker container on remote server. Exiting."
  exit 1
fi

# 清理本地临时文件
echo "Cleaning up..."
rm -f $IMAGE_TAR

echo "Deployment completed successfully."
