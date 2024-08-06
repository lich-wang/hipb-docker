import os
import requests
import threading
from queue import Queue
from datetime import datetime

# 设置日志文件和响应目录
LOG_FILE = "pwnedpasswords_log.txt"
RESPONSE_DIR = "responses"

# 检查日志文件和响应目录是否存在，如果不存在则创建
if not os.path.exists(LOG_FILE):
    with open(LOG_FILE, 'w') as f:
        pass

if not os.path.exists(RESPONSE_DIR):
    os.makedirs(RESPONSE_DIR)

# 定义一个函数来处理单个哈希前缀
def process_hash_prefix(queue):
    while not queue.empty():
        hash_prefix = queue.get()
        url = f"https://api.pwnedpasswords.com/range/{hash_prefix}"

        # 记录请求开始时间
        request_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        try:
            response = requests.get(url)
            response_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            http_code = response.status_code
            response_content = response.text
            time_taken = response.elapsed.total_seconds()

            # 将请求开始时间、结束时间、HTTP状态码和耗时记录到日志文件
            log_entry = (f"Hash Prefix: {hash_prefix}, Request Time: {request_time}, "
                         f"Response Time: {response_time}, HTTP Code: {http_code}, "
                         f"Time Taken: {time_taken} seconds\n")
            with open(LOG_FILE, 'a') as log_file:
                log_file.write(log_entry)

            # 将响应内容保存到单独的文件中
            response_file = os.path.join(RESPONSE_DIR, f"response_{hash_prefix}.txt")
            with open(response_file, 'w') as file:
                file.write(response_content)

        except requests.RequestException as e:
            print(f"Error fetching {hash_prefix}: {e}")

        queue.task_done()

# 生成前100个哈希前缀
def generate_hash_prefixes():
    for i in range(100):  # 仅生成前100个前缀
#   for i in range(0x00000, 0x100000):  # 生成从0x00000到0xFFFFF的所有前缀

        yield f"{i:05X}"

def main():
    # 创建一个队列并将所有哈希前缀放入其中
    queue = Queue()
    for prefix in generate_hash_prefixes():
        queue.put(prefix)

    # 启动多个线程来处理队列中的哈希前缀
    threads = []
    for _ in range(8):  # 8个线程，可以根据需要调整
        thread = threading.Thread(target=process_hash_prefix, args=(queue,))
        thread.start()
        threads.append(thread)

    # 等待所有线程完成
    for thread in threads:
        thread.join()

if __name__ == "__main__":
    main()
