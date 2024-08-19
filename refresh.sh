#!/bin/bash

# 远程API的基础URL
BASE_URL="http://49.234.185.20:8000/range/"

# 日志文件
LOG_FILE="initial_requests.log"

# 开始前缀和结束前缀
START_PREFIX=0x00000
END_PREFIX=0xFFFFF

# 无限循环
while true; do
  for ((prefix=START_PREFIX; prefix<=END_PREFIX; prefix++)); do
    # 将前缀转换为大写的五位十六进制字符串
    HEX_PREFIX=$(printf "%05X" $prefix)
    
    # 构建完整的URL
    FULL_URL="${BASE_URL}${HEX_PREFIX}"

    # 记录请求开始时间
    echo "Requesting: $FULL_URL" | tee -a $LOG_FILE
    START_TIME=$(date +%s)

    # 发送请求
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $FULL_URL)

    # 记录请求结束时间
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    # 记录响应信息
    if [ "$RESPONSE" -eq 200 ]; then
      echo "[$(date)] Success: $FULL_URL (Duration: ${DURATION}s)" | tee -a $LOG_FILE
    else
      echo "[$(date)] Failure: $FULL_URL (HTTP Status: $RESPONSE, Duration: ${DURATION}s)" | tee -a $LOG_FILE
    fi
  done

  # 当结束前缀达到后，重置并重新开始
  echo "Reached the end of range. Restarting..." | tee -a $LOG_FILE
done
