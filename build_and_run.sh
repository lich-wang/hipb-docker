#!/bin/bash

# 确保脚本在发生错误时退出
set -e

# 设置Docker镜像名称和标签
IMAGE_NAME="pwnedpasswords"
TAG="live"
PORT=8000

# 构建Docker镜像
echo "Building Docker image with tag ${TAG}..."
docker build --network=host -t ${IMAGE_NAME}:${TAG} .

# 检查并停止运行的同名容器
if [ "$(docker ps -aq -f name=${IMAGE_NAME})" ]; then
  echo "Stopping and removing existing container..."
  docker stop ${IMAGE_NAME} && docker rm ${IMAGE_NAME}
fi

# 运行Docker容器
echo "Running Docker container..."
docker run -d -p ${PORT}:8000 --name ${IMAGE_NAME} ${IMAGE_NAME}:${TAG}

# 检查容器状态
echo "Checking container status..."
sleep 5  # 等待容器启动
if [ "$(docker ps -aq -f name=${IMAGE_NAME} -f status=exited)" ]; then
  echo "Container exited unexpectedly. Showing logs:"
  docker logs ${IMAGE_NAME}
else
  echo "Docker container is running. Access it at http://localhost:${PORT}"
fi
