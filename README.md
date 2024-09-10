
# PwnedPasswords Docker Project

这是一个基于 Docker 构建的应用程序，用于检查密码是否曾经泄露。通过请求 API (`https://api.pwnedpasswords.com/range/`) 获取密码哈希的部分，来判断密码的安全性。前端提供了一个简单的 Web 页面，用户可以输入密码并检查它是否泄露过。

## 项目目录结构

```bash
.
├── build_and_run.sh            # 本地构建和运行 Docker 镜像的脚本
├── deploy.log                  # 部署日志文件，记录执行的详细过程
├── deploy_to_remote.sh         # 部署 Docker 镜像到远程服务器的脚本
├── Dockerfile                  # Docker 镜像构建文件
├── index.html                  # Web 前端页面，允许用户输入密码检查
├── initial_remote.sh           # 本地将 `refresh.sh` 传输到远程并执行的脚本
├── nohup.out                   # `nohup` 命令的输出文件，用于后台运行的日志
├── pwned_passwords_downloader.py # 一个辅助下载密码数据的 Python 脚本 (可选)
├── refresh.sh                  # 远程执行的脚本，用于循环从远程 API 获取密码哈希数据
└── service.py                  # FastAPI 服务文件，处理来自前端的请求并与 API 交互
```

## 各文件解释

- **build_and_run.sh**: 
  本地构建 Docker 镜像并运行服务的脚本。它会根据当前的代码生成一个 Docker 镜像并在本地运行容器。
  
- **deploy.log**: 
  部署的日志文件，记录了每次执行部署时发生的过程和错误信息。
  
- **deploy_to_remote.sh**: 
  部署脚本，将本地构建的 Docker 镜像传输到远程服务器，并在远程服务器上启动 Docker 容器。

- **Dockerfile**: 
  定义 Docker 镜像的构建步骤，包括如何安装依赖、复制文件以及启动服务。
  
- **index.html**: 
  一个简单的 Web 页面，允许用户输入密码并通过后端 API 检查密码是否泄露。

- **initial_remote.sh**: 
  用于将 `refresh.sh` 传输到远程服务器并在后台执行的脚本。

- **nohup.out**: 
  当你使用 `nohup` 命令后台执行脚本时，输出会记录在该文件中。

- **pwned_passwords_downloader.py**: 
  可选的 Python 脚本，用于从 `api.pwnedpasswords.com` 批量下载密码泄露数据。

- **refresh.sh**: 
  远程服务器上的脚本，自动从 `api.pwnedpasswords.com` 拉取密码哈希数据，并保存在本地缓存中以便日后使用。

- **service.py**: 
  FastAPI 服务，提供了密码检查的后端 API。接收前端请求并处理密码哈希数据的比对。

## 如何构建和运行

### 1. 从 Docker Hub 拉取镜像并运行

你可以直接从 Docker Hub 拉取并运行镜像，而无需自己构建：

```bash
docker pull <your_dockerhub_username>/pwnedpasswords:live
docker run -d -p 8000:8000 <your_dockerhub_username>/pwnedpasswords:live
```

然后，访问 `http://localhost:8000` 查看页面。

### 2. 本地构建 Docker 镜像

如果你想在本地进行构建，执行以下步骤：

1. 克隆项目代码：

    ```bash
    git clone https://github.com/<your_github_username>/pwnedpasswords.git
    cd pwnedpasswords
    ```

2. 使用 `build_and_run.sh` 脚本构建并运行 Docker 容器：

    ```bash
    ./build_and_run.sh
    ```

3. 服务将运行在 `http://localhost:8000`。

### 3. 部署到远程服务器

如果你需要将镜像部署到远程服务器，你可以使用 `deploy_to_remote.sh`。

1. 修改 `deploy_to_remote.sh` 中的远程服务器 IP 和路径。

2. 运行以下命令将本地构建的 Docker 镜像传输到远程服务器并启动容器：

    ```bash
    ./deploy_to_remote.sh
    ```

### 4. 刷新远程 API 缓存

为了保证服务器上的缓存是最新的，你可以在远程服务器上执行 `refresh.sh`。这个脚本将自动请求 API，并将结果存储在服务器上。

1. 你可以使用 `initial_remote.sh` 脚本将 `refresh.sh` 传输到远程服务器并开始执行：

    ```bash
    ./initial_remote.sh
    ```

2. 脚本会在后台持续执行，请求 `api.pwnedpasswords.com` 并更新远程缓存文件。

## 持久化存储

为了确保缓存的数据不会在容器重启后丢失，Docker 中的 `responses` 文件夹已经设置为持久化存储。你可以通过以下命令将本地文件夹挂载到容器：

```bash
docker run -d -p 8000:8000 -v /path/to/local/responses:/app/responses <your_dockerhub_username>/pwnedpasswords:live
```

## 日志和调试

所有的请求和操作都将记录在日志文件中。你可以通过以下方式查看：

- 本地日志文件：`deploy.log`
- 远程服务器上的日志文件：`/root/refresh.log`

## 贡献

欢迎你提交 issue 或 pull request，帮助我们改进这个项目。

---


