import os
import requests
import threading
from queue import Queue
from datetime import datetime
import sys
import time
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# 设置日志文件和响应目录
LOG_FILE = "/app/pwnedpasswords_log.txt"  # 使用绝对路径
RESPONSE_DIR = "/app/responses"  # 使用绝对路径

# 检查日志文件和响应目录是否存在，如果不存在则创建
if not os.path.exists(LOG_FILE):
    with open(LOG_FILE, 'w') as f:
        pass

if not os.path.exists(RESPONSE_DIR):
    os.makedirs(RESPONSE_DIR)

# 定义请求函数，添加重试和超时机制
def fetch_with_retry(url):
    session = requests.Session()
    retry = Retry(
        total=5,  # 重试次数
        backoff_factor=1,  # 重试之间的等待时间，指数增加
        status_forcelist=[429, 500, 502, 503, 504]  # 针对哪些状态码进行重试
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)

    return session.get(url, timeout=2)  # 设置请求超时时间为10秒

# 定义一个函数来处理单个哈希前缀
def process_hash_prefix(queue):
    while not queue.empty():
        hash_prefix = queue.get().lower()  # 确保前缀为小写
        url = f"https://api.pwnedpasswords.com/range/{hash_prefix.upper()}"  # API请求使用大写
        request_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        try:
            response = fetch_with_retry(url)
            response_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            http_code = response.status_code
            response_content = response.text
            time_taken = response.elapsed.total_seconds()

            log_entry = (f"Hash Prefix: {hash_prefix.upper()}, Request Time: {request_time}, "
                         f"Response Time: {response_time}, HTTP Code: {http_code}, "
                         f"Time Taken: {time_taken} seconds\n")
            with open(LOG_FILE, 'a') as log_file:
                log_file.write(log_entry)

            response_file = os.path.join(RESPONSE_DIR, f"response_{hash_prefix}.txt")
            with open(response_file, 'w') as file:
                file.write(response_content)

        except requests.RequestException as e:
            print(f"Error fetching {hash_prefix}: {e}")

        queue.task_done()

# 生成指定数量的哈希前缀
def generate_hash_prefixes(limit):
    for i in range(limit):
        yield f"{i:05X}"

def main(limit):
    # 创建一个队列并将所有哈希前缀放入其中
    queue = Queue()
    for prefix in generate_hash_prefixes(limit):
        queue.put(prefix)

    # 启动多个线程来处理队列中的哈希前缀
    threads = []
    for _ in range(32):  # 32个线程，可以根据需要调整
        thread = threading.Thread(target=process_hash_prefix, args=(queue,))
        thread.start()
        threads.append(thread)

    # 等待所有线程完成
    for thread in threads:
        thread.join()

if __name__ == "__main__":
    limit = int(sys.argv[1]) if len(sys.argv) > 1 else 1000000
    main(limit)
