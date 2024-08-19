#!/bin/bash

# 远程服务器信息
REMOTE_SERVER="root@49.234.185.20"
REMOTE_DIR="/root"

# 本地的 refresh.sh 脚本路径
REFRESH_SCRIPT="refresh.sh"

# 传输 refresh.sh 到远程服务器
echo "Transferring refresh.sh to remote server..."
scp $REFRESH_SCRIPT $REMOTE_SERVER:$REMOTE_DIR

if [ $? -ne 0 ]; then
  echo "Failed to transfer refresh.sh. Exiting."
  exit 1
fi

# 在远程服务器上执行 refresh.sh 脚本并在后台运行
echo "Executing refresh.sh on remote server..."
ssh $REMOTE_SERVER << EOF
  chmod +x $REMOTE_DIR/refresh.sh
  nohup $REMOTE_DIR/refresh.sh > $REMOTE_DIR/refresh.log 2>&1 &
EOF

if [ $? -ne 0 ]; then
  echo "Failed to execute refresh.sh on remote server. Exiting."
  exit 1
fi

echo "refresh.sh is now running in the background on the remote server."
