# 개발 워크스테이션 미션 수행 기록

## 미션 목표

터미널, Docker, Git/GitHub를 사용해 개발 환경을 구성하고, 실행 명령과 검증 결과를 기록한다.

## 수행 체크리스트

- [x] 터미널 기본 명령과 경로 확인
- [x] 파일 및 디렉터리 권한 확인·변경
- [x] Docker 버전과 엔진 상태 확인
- [x] `hello-world`와 Ubuntu 컨테이너 실행
- [x] 컨테이너 `attach`와 `exec` 차이 확인
- [x] Docker 이미지·컨테이너 목록, 로그, 통계 확인
- [x] Dockerfile 작성 및 커스텀 웹 서버 이미지 빌드
- [x] 포트 매핑 후 `curl`로 접속 확인
- [x] 바인드 마운트 파일 변경 반영 확인
- [x] 컨테이너 삭제 후 named volume 데이터 유지 확인
- [x] Git 설정과 VS Code/GitHub 연동 확인
- [x] 보너스: Compose 단일 서비스 실행
- [x] 보너스: Compose 웹+보조 서비스 통신 확인
- [x] 보너스: `up`, `down`, `ps`, `logs` 실행 기록
- [x] 보너스: Compose 환경 변수 적용
- [x] 보너스: GitHub SSH 인증 확인

## 실행 환경

- OS: Ubuntu 26.04.1 LTS (WSL)
- 셸/터미널: WSL Bash
- Docker: 29.9.2, build `a82e528`
- Git: 2.53.0
- Docker Compose: v5.6.1
- 저장소: `git@github.com:yiel12/my-study.git`
- 브랜치: `main`

## 터미널 기본 명령 및 경로

연습 폴더는 `/home/yiel12/workstation-mission-practice`에 만들었다.

```bash
mkdir -p ~/workstation-mission-practice
cd ~/workstation-mission-practice
pwd
whoami
mkdir terminal-demo
touch terminal-demo/note.txt
printf 'Hello from the terminal\n' > terminal-demo/note.txt
cat terminal-demo/note.txt
cp terminal-demo/note.txt note-copy.txt
mv note-copy.txt note-renamed.txt
ls -la
rm note-renamed.txt
```

파일 내용은 `Hello from the terminal`이었다. `terminal-demo/note.txt`는 현재 위치 기준 상대 경로이고, `/home/yiel12/workstation-mission-practice/terminal-demo/note.txt`는 루트(`/`)부터 지정한 절대 경로다. 두 경로로 같은 파일을 확인했다.

실제 경로와 파일 목록을 확인한 출력 (2026-11-17):

```text
$ pwd
/home/yiel12/workstation-mission-practice

$ ls -l
total 4
drwxr-xr-x 2 yiel12 yiel12 4096 Nov  9 21:30 terminal-demo

$ ls -l terminal-demo
total 4
-rw-r--r-- 1 yiel12 yiel12 24 Nov  9 21:30 note.txt
```

### 파일 생성·복사·이동·삭제 실제 출력 (2026-11-17)

연습용 새 폴더에서 명령을 실행했다. `touch -v`는 지원되지 않는 옵션이라 오류가 났고, `printf`의 출력 리디렉션으로 파일을 만들었다.

```text
$ mkdir -v terminal-ops-demo-20261117
mkdir: created directory 'terminal-ops-demo-20261117'

$ touch -v note.txt
error: unexpected argument '-v' found

$ printf 'Terminal file operations evidence\n' > note.txt
$ cat note.txt
Terminal file operations evidence

$ cp -v note.txt note-copy.txt
'note.txt' -> 'note-copy.txt'

$ mv -v note-copy.txt note-renamed.txt
renamed 'note-copy.txt' -> 'note-renamed.txt'

$ ls -l
total 8
-rw-r--r-- 1 yiel12 yiel12 34 Nov 17 17:15 note-renamed.txt
-rw-r--r-- 1 yiel12 yiel12 34 Nov 17 17:15 note.txt

$ rm -v note-renamed.txt
removed 'note-renamed.txt'

$ ls -l
total 4
-rw-r--r-- 1 yiel12 yiel12 34 Nov 17 17:15 note.txt
```

## 파일 및 디렉터리 권한

```text
초기 상태:
drwxr-xr-x (755) terminal-demo
-rw-r--r-- (644) terminal-demo/note.txt

파일:
chmod 600 terminal-demo/note.txt  → -rw------- (600)
chmod 644 terminal-demo/note.txt  → -rw-r--r-- (644)

디렉터리:
chmod 700 terminal-demo           → drwx------ (700)
chmod 755 terminal-demo           → drwxr-xr-x (755)
```

권한 숫자는 소유자·그룹·기타 사용자 순서다. 읽기 `r=4`, 쓰기 `w=2`, 실행/접근 `x=1`을 더해 표시한다. 파일 권한 `644`는 소유자가 읽고 쓸 수 있고 나머지는 읽을 수 있다는 뜻이다. 디렉터리의 `x` 권한은 내부 항목에 접근할 수 있게 한다.

현재 권한 확인 출력 (2026-11-17):

```text
drwxr-xr-x (755) terminal-demo
-rw-r--r-- (644) terminal-demo/note.txt
```

`ls -l`의 문자 권한과 `stat`의 숫자 권한이 각각 디렉터리 `755`, 파일 `644`임을 보여준다.

### 추가 권한 조합 확인 (2026-11-17)

```text
chmod 640 terminal-demo/note.txt
chmod 750 terminal-demo
drwxr-x--- (750) terminal-demo
-rw-r----- (640) terminal-demo/note.txt
```

`750`은 소유자에게 읽기·쓰기·접근 권한, 그룹에는 읽기·접근 권한을 주고 기타 사용자 권한은 주지 않는다. 파일 `640`은 소유자에게 읽기·쓰기, 그룹에는 읽기만 주고 기타 사용자 권한은 주지 않는다. 확인 후 디렉터리는 `755`, 파일은 `644`로 복구했다.

```text
drwxr-xr-x (755) terminal-demo
-rw-r--r-- (644) terminal-demo/note.txt
```

## GitHub 및 VS Code 연동

VS Code에서 저장소 파일을 만들고 수정했으며, WSL 터미널에서 Git으로 변경을 확인하고 커밋·push했다.

```bash
git remote -v
git status --short --branch
```

GitHub SSH 인증을 설정하고 연결을 확인했다.

```text
ssh -T git@github.com
Hi yiel12! You've successfully authenticated, but GitHub does not provide shell access.
```

HTTPS push에서 GitHub 계정 비밀번호 인증이 거부된 뒤 SSH 원격 주소를 설정해 push했다.

```bash
git remote set-url origin git@github.com:yiel12/my-study.git
git push origin main
```

비밀 키, 토큰, 공개 키 내용은 저장소나 이 기록에 넣지 않았다.

### GitHub push 성공 출력 (2026-11-17)

WSL에서 GitHub SSH 포트 연결이 되지 않아 Windows PowerShell의 Git Credential Manager를 사용해 HTTPS로 push했다. SSH 원격 주소는 변경하지 않았다.

```text
PS> git push https://github.com/yiel12/my-study.git main:main
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 14 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 4.10 KiB | 4.10 MiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To https://github.com/yiel12/my-study.git
   2f260b2..67cdd30  main -> main
```

원격 추적 정보를 갱신한 뒤 `git status --short --branch`에서 `## main...origin/main`을 확인했다. 현재 보완 중인 변경 사항은 별도 커밋 후 push해야 한다.

### 저장소 루트 구조와 파일 배치 기준

실행 결과는 Git이 추적하는 파일만 표시한다. 저장소 루트에 Docker 빌드에 필요한 파일을 함께 두어 `docker build .`에서 `Dockerfile`이 `index.html`을 찾을 수 있게 했다. `.dockerignore`는 빌드 문맥에 불필요한 파일이 들어가지 않게 하고, `compose.yaml`에는 웹·보조 서비스와 포트 설정을 모아 재현 가능하게 했다.

```text
my-study/
├── .dockerignore
├── Dockerfile
├── README.md
├── command-history.txt
├── compose.yaml
├── index.html
```

- `Dockerfile`: NGINX 이미지를 만들고 웹 페이지 파일을 복사한다.
- `index.html`: 웹 서버가 반환하는 페이지다.
- `.dockerignore`: Docker 빌드 문맥에서 불필요한 파일을 제외한다.
- `compose.yaml`: Compose 서비스, 네트워크, 포트 설정을 정의한다.
- `README.md`: 수행 절차와 실제 검증 결과를 기록한다.
- `command-history.txt`: 터미널에서 사용한 명령어 이력을 보관한다.

## Docker 엔진 확인 및 기본 컨테이너

```bash
docker --version
# Docker version 29.9.2, build a82e528

docker info --format 'Server={{.ServerVersion}} Containers={{.Containers}} Running={{.ContainersRunning}} Stopped={{.ContainersStopped}} Images={{.Images}}'
# Server=29.9.2 Containers=1 Running=0 Stopped=1 Images=3
```
### Docker 엔진 전체 상태 출력

처음에는 WSL에서 Docker CLI를 찾지 못했다. Docker Desktop의 WSL Integration을 켠 뒤 `docker info`가 동작했다. 확인 시점의 Docker Client·Server 버전은 `29.9.3`, Compose 플러그인은 `v5.7.0`이었다.

```text
Client:
 Version:    29.9.3
 Context:    default
 Debug Mode: false
 Plugins:
  agent: Docker AI Agent Runner (Docker Inc.)
    Version:  v1.153.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-agent
  ai: Docker AI Agent - Ask Gordon (Docker Inc.)
    Version:  v1.33.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-ai
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.38.1
    Path:     /usr/local/lib/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v5.7.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-compose
  debug: Get a shell into any image or container (Docker Inc.)
    Version:  0.49.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-debug
  desktop: Docker Desktop commands (Docker Inc.)
    Version:  4.99.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-desktop
  dhi: CLI for managing Docker Hardened Images (Docker Inc.)
    Version:  v0.0.10
    Path:     /usr/local/lib/docker/cli-plugins/docker-dhi
  extension: Manages Docker extensions (Docker Inc.)
    Version:  v0.2.32
    Path:     /usr/local/lib/docker/cli-plugins/docker-extension
  init: Creates Docker-related starter files for your project (Docker Inc.)
    Version:  v1.4.1
    Path:     /usr/local/lib/docker/cli-plugins/docker-init
  mcp: Docker MCP Plugin (Docker Inc.)
    Version:  v0.44.3
    Path:     /usr/local/lib/docker/cli-plugins/docker-mcp
  model: Docker Model Runner (Docker Inc.)
    Version:  v1.2.9
    Path:     /usr/local/lib/docker/cli-plugins/docker-model
  offload: Docker Offload (Docker Inc.)
    Version:  v0.7.36
    Path:     /usr/local/lib/docker/cli-plugins/docker-offload
  pass: Docker Pass Secrets Manager Plugin (beta) (Docker Inc.)
    Version:  v0.3.2
    Path:     /usr/local/lib/docker/cli-plugins/docker-pass
  sandbox: "docker sandbox" is deprecated, use Docker Sandboxes instead (Docker Inc.)
    Version:  v0.13.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-sandbox
  scout: Docker Scout (Docker Inc.)
    Version:  v1.28.0
    Path:     /usr/local/lib/docker/cli-plugins/docker-scout

Server:
 Containers: 1
  Running: 0
  Paused: 0
  Stopped: 1
 Images: 6
 Server Version: 29.9.3
 Storage Driver: overlayfs
  driver-type: io.containerd.snapshotter.v1
 Logging Driver: local
 Cgroup Driver: cgroupfs
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 CDI spec directories:
  /etc/cdi
  /var/run/cdi
 Discovered Devices:
  cdi: docker.com/gpu=webgpu
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 nvidia runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: b7a25261e029d68978bbf290df0a62fc819b3c51
 runc version: v1.5.2-0-g29dd3dc2
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  cgroupns
 Kernel Version: 6.18.58.1-microsoft-standard-WSL2
 Operating System: Docker Desktop
 OSType: linux
 Architecture: x86_64
 CPUs: 14
 Total Memory: 7.52GiB
 Name: docker-desktop
 ID: fa941bfb-14c3-4b0c-8b9d-b9a316c828b9
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 HTTP Proxy: http.docker.internal:3128
 HTTPS Proxy: http.docker.internal:3128
 No Proxy: hubproxy.docker.internal
 Labels:
  com.docker.desktop.address=unix:///var/run/docker-cli.sock
 Experimental: false
 Insecure Registries:
  hubproxy.docker.internal:5555
  127.0.0.0/8
  ::1/128
 Live Restore Enabled: false
 Firewall Backend: iptables

```

### Docker hello-world 실행

`hello-world` 이미지를 실행해 Docker 데몬이 이미지로 컨테이너를 만들고 실행하는 것을 확인했다.

```bash
docker run hello-world
```
출력에는 `Hello from Docker!`와 설치가 정상 동작한다는 안내가 표시됐다.


2026-11-17 재실행 결과:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from the image. It runs the
    executable that produces the output shown here.
 4. The Docker daemon streamed the output to the Docker client, which sent it
    to the terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

## Ubuntu 컨테이너, `attach`, `exec`, `exit`

```bash
docker run -dit --name ubuntu-lab ubuntu bash
docker ps --filter name=ubuntu-lab
```

컨테이너가 `Up` 상태인 것을 확인한 뒤 `docker attach ubuntu-lab`으로 주 Bash에 연결해 `pwd`, `ls`, `echo`를 실행했다. `Ctrl+P`, `Ctrl+Q`로 연결만 분리했을 때 컨테이너는 계속 실행됐다.

```bash
docker exec -it ubuntu-lab bash
pwd
ls
echo "hello from exec shell"
exit
docker ps --filter name=ubuntu-lab
```

`exec`로 연 별도 Bash에서 `exit`해도 컨테이너 주 프로세스는 계속 실행됐다. 이후 `attach`로 주 Bash에 다시 연결해 `exit`하자 컨테이너가 `Exited (0)` 상태가 됐다.

- `attach`는 컨테이너 주 프로세스의 입출력에 연결한다. 연결만 분리하면 주 프로세스는 계속 실행되지만, 주 Bash를 종료하면 컨테이너도 종료된다.
- `exec`는 실행 중인 컨테이너 안에 별도 프로세스를 시작한다. 그 프로세스에서 `exit`해도 주 프로세스는 계속 실행된다.

## Docker 이미지·컨테이너 운영

```text
$ docker images
hello-world:latest
nginx:latest
ubuntu:latest
```

`docker ps -a`에서 미션용 Ubuntu와 `hello-world` 컨테이너가 종료된 상태인 것을 확인했다. 기존 `my-web-server` 컨테이너는 이미 중지 상태였고 실습에서 변경하거나 삭제하지 않았다.

```bash
docker logs priceless_pare
```

로그에서 `Hello from Docker!`를 확인했다.

```text
$ docker stats --no-stream ubuntu-lab
CPU: 0.00%
Memory: 2.242MiB / 7.52GiB (0.03%)
Network I/O: 1.17kB / 126B
Block I/O: 0B / 0B
Processes: 1
```

미션용 `ubuntu-lab` 컨테이너는 실습 후 중지했다. 이후 테스트 컨테이너를 정리할 때 기존 `my-web-server`는 그대로 두었다.

### 이미지와 컨테이너 목록 원시 출력 (2026-11-17)

```text
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS                     PORTS     NAMES
f48863464d42   hello-world   "/hello"                 4 minutes ago   Exited (0) 4 minutes ago             optimistic_jackson
971b70d96369   nginx         "/docker-entrypoint.…"   2 weeks ago     Exited (137) 2 weeks ago             my-web-server
```

```text
$ docker images
IMAGE                  ID             DISK USAGE   CONTENT SIZE   EXTRA
busybox:latest         a46257e06c82       6.81MB         2.23MB
hello-world:latest     c567b231f656       25.9kB         9.49kB    U
my-study-web:1.0       466c2361b457        241MB         63.9MB
my-study-web:compose   f999dde84cd6        241MB         63.9MB
nginx:latest           5ab5b0b01097        243MB         66.8MB    U
ubuntu:latest          6a06111c3b0a        163MB         45.9MB
```

`my-web-server`는 실습 전부터 있던 중지 컨테이너이므로 그대로 두었다. `U`는 Docker 이미지 목록 화면에서 사용 중임을 표시한 항목이다.

## 커스텀 NGINX 이미지 빌드

저장소 루트의 `Dockerfile`:

```dockerfile
FROM nginx:latest
LABEL org.opencontainers.image.title="my-study-mission"
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

`.dockerignore`:

```text
*
!Dockerfile
!index.html
```

Dockerfile과 웹 페이지 파일만 빌드 문맥에 포함되도록 했다.

```bash
docker build -t my-study-web:1.0 .
```

빌드가 완료됐고 NGINX 기본 웹 폴더에 저장소의 `index.html`을 복사한 것을 확인했다.

### Docker 이미지 빌드 원시 출력 (2026-11-17)

```text
#0 building with "default" instance using docker driver
#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 174B 0.0s done
#1 DONE 0.1s
#2 [internal] load metadata for docker.io/library/nginx:latest
#2 DONE 0.1s
#3 [internal] load .dockerignore
#3 transferring context: 67B 0.0s done
#3 DONE 0.0s
#4 [internal] load build context
#4 transferring context: 32B 0.0s done
#4 DONE 0.0s
#5 [1/2] FROM docker.io/library/nginx:latest@sha256:5ab5b0b01097420873a3f3330f44248e34a3c2a3e8d5ee30658aeae8cb7435da
#5 resolve docker.io/library/nginx:latest@sha256:5ab5b0b01097420873a3f3330f44248e34a3c2a3e8d5ee30658aeae8cb7435da 0.0s done
#5 DONE 0.1s
#6 [2/2] COPY index.html /usr/share/nginx/html/index.html
#6 CACHED
#7 exporting to image
#7 exporting layers done
#7 exporting manifest sha256:8226564b7bed5eb3fa538ea3f06053797886059c3defa1f45a4ab7c8e2366f87 0.0s done
#7 exporting config sha256:c44359132cc28a11d6ffb9fa1b9727d251a6e0f24db988e7080b868086b75f33 0.0s done
#7 exporting attestation manifest sha256:0fbfa4e02f7a231e39d2b22eb2c8128cd8749df8bab9ebef0be018348b718f31 0.0s done
#7 exporting manifest list sha256:ec18a0ea17c5d76c4299edd9c0f7df1672893312770bd21dbf2b4e34772f894b 0.0s done
#7 naming to docker.io/library/my-study-web:1.0 done
#7 unpacking to docker.io/library/my-study-web:1.0 0.0s done
#7 DONE 0.2s
```

## 네트워크 네임스페이스와 포트 매핑

컨테이너는 자체 네트워크 네임스페이스를 사용해 호스트와 분리된 네트워크 인터페이스, IP 주소, 경로, 포트 공간을 가진다. 따라서 컨테이너 안의 80번 포트와 호스트의 `localhost:80`은 같은 주소가 아니며, 호스트 요청이 컨테이너로 자동 전달되지 않는다.

Docker의 `-p 8080:80` 설정은 호스트의 8080번 포트로 들어온 요청을 컨테이너 IP의 80번 포트로 전달(포트 포워딩)한다. 같은 Docker 네트워크 안의 컨테이너는 포트를 호스트에 공개하지 않아도 서비스 이름으로 통신할 수 있다. 호스트나 외부에서 접속할 서비스를 공개할 때 포트 매핑을 사용한다.

```bash
docker run -d --name mission-web-8080 -p 8080:80 my-study-web:1.0
docker ps --filter name=mission-web-8080
curl --max-time 5 -i http://localhost:8080
```

컨테이너 상태에 `0.0.0.0:8080->80/tcp`가 표시됐고, `curl`은 `HTTP/1.1 200 OK`와 저장소의 HTML을 반환했다.

### 네임스페이스와 포트 포워딩 확인 출력 (2026-11-17)

```text
$ readlink /proc/self/ns/net
net:[4026531833]

$ docker exec mission-web-evidence readlink /proc/self/ns/net
net:[4026532476]

$ docker inspect --format '{{range .NetworkSettings.Networks}}Network={{.NetworkID}} IP={{.IPAddress}}{{end}}' mission-web-evidence
Network=1f02bc91c60ea9f1ad173b6585495ea7495cf84f907cda3780ec3f8c6091a1e3 IP=172.17.0.2

$ docker port mission-web-evidence
80/tcp -> 0.0.0.0:8080
80/tcp -> [::]:8080

$ ss -ltnp | grep ':8080'
LISTEN 0 4096 *:8080 *:*
```

WSL과 컨테이너의 네트워크 네임스페이스 ID가 달랐다. `docker port`는 컨테이너의 80번 포트를 호스트의 IPv4·IPv6 8080번 포트에 연결한 것을 보여준다. `ss`에서도 8080번 포트가 LISTEN 상태임을 확인했다.

### 포트 매핑 및 HTTP 응답 원시 출력 (2026-11-17)

```text
$ docker ps --filter name=mission-web-evidence
CONTAINER ID   IMAGE              COMMAND                  CREATED          STATUS         PORTS                                     NAMES
c5ca26c970c4   my-study-web:1.0   "/docker-entrypoint.…"   10 seconds ago   Up 9 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   mission-web-evidence
```

```text
$ curl --max-time 5 -i http://localhost:8080
HTTP/1.1 200 OK
Server: nginx/1.31.8
Date: Tue, 17 Nov 2026 07:43:00 GMT
Content-Type: text/html
Content-Length: 253
Last-Modified: Mon, 09 Nov 2026 13:23:07 GMT
Connection: keep-alive
ETag: "6af1c93b-fd"
Accept-Ranges: bytes

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>나의 첫 웹 서버</title>
</head>
<body>
<h1>안녕, 바인드 마운트!</h1>
<p>호스트 파일 수정이 컨테이너에 바로 반영됐습니다.</p>
</body>
</html>
```

### 빌드·실행·변경 확인 흐름 (2026-11-17)

1. `Dockerfile`과 `index.html`로 이미지를 빌드했다. 이 재실행에서는 Docker가 `COPY index.html` 단계를 `CACHED`로 재사용했고 빌드가 완료됐다.
2. 이미지를 포트 매핑해 컨테이너를 실행했다. `docker ps`에 `0.0.0.0:8080->80/tcp`가 표시됐고, `curl`은 HTTP 200과 HTML을 반환했다.
3. 바인드 마운트 실습에서 호스트의 `index.html`을 수정한 뒤 페이지를 다시 요청했다. 수정 문구가 바로 표시돼, 바인드 마운트에서는 호스트 파일 변경이 이미지 재빌드 없이 반영됨을 확인했다.
4. 바인드 마운트가 없는 일반 이미지 컨테이너는 이미지 안의 파일을 사용하므로, 새 HTML을 이미지에 포함하려면 다시 빌드하고 새 컨테이너를 실행해야 한다.

핵심 로그:

```text
빌드: #6 [2/2] COPY index.html /usr/share/nginx/html/index.html
      #6 CACHED
      #7 DONE 0.2s

실행: container c5ca26c970c4
      0.0.0.0:8080->80/tcp

접속: HTTP/1.1 200 OK
      <h1>안녕, 바인드 마운트!</h1>
      <p>호스트 파일 수정이 컨테이너에 바로 반영됐습니다.</p>
```

## 바인드 마운트와 실시간 파일 변경

저장소의 `index.html`을 NGINX 컨테이너 파일에 읽기 전용으로 연결했다.

```bash
docker stop mission-web-8080
docker run -d --name mission-web-bind -p 8080:80 \
  --mount type=bind,source="$(pwd)/index.html",target=/usr/share/nginx/html/index.html,readonly \
  my-study-web:1.0

docker inspect --format '{{range .Mounts}}{{.Type}} destination={{.Destination}} read-write={{.RW}}{{end}}' mission-web-bind
```

확인 결과는 다음과 같았다.

```text
bind destination=/usr/share/nginx/html/index.html read-write=false
```

호스트의 `index.html`을 수정한 뒤 브라우저에서 `http://localhost:8080/`을 다시 열었다. 이미지 재빌드 없이 다음 새 문구가 표시됐다.

```html
<h1>안녕, 바인드 마운트!</h1>
<p>호스트 파일 수정이 컨테이너에 바로 반영됐습니다.</p>
```

## Named volume 데이터 영속성

```bash
docker volume create mission-data-20261109
docker run -d --name volume-first \
  --mount type=volume,source=mission-data-20261109,target=/data \
  ubuntu sleep infinity

docker exec volume-first sh -c 'echo "Persistent data test" > /data/hello.txt && cat /data/hello.txt'
```

첫 번째 컨테이너에서 `Persistent data test`를 기록하고 읽었다. 컨테이너를 삭제한 뒤 같은 볼륨을 새 컨테이너에 연결했다.

```bash
docker rm -f volume-first
docker run -d --name volume-second \
  --mount type=volume,source=mission-data-20261109,target=/data \
  ubuntu sleep infinity

docker ps -a --filter name=volume-first
docker exec volume-second cat /data/hello.txt
```

첫 번째 컨테이너는 목록에서 사라졌지만 새 컨테이너에서 `Persistent data test`를 다시 읽었다. Named volume은 컨테이너와 별도로 유지되지만, 볼륨 자체가 삭제되거나 손상되는 상황에 대비하려면 별도 백업도 필요하다.

### 바인드 마운트와 named volume 선택 기준

- 바인드 마운트는 특정 호스트 경로를 컨테이너 경로에 연결한다. 소스 코드처럼 호스트에서 직접 편집하고 즉시 반영할 파일에 적합하다. 호스트 파일 경로가 존재해야 하고, 호스트의 디렉터리 구조에 의존한다.
- Named volume은 Docker가 관리하는 저장 공간이다. 데이터베이스 파일이나 애플리케이션 데이터처럼 컨테이너를 지운 뒤에도 보존할 데이터에 적합하다. 컨테이너와 별도로 남지만, 볼륨 자체의 삭제나 손상에 대비해 별도 백업이 필요하다.
- 이번 실습에서는 웹 페이지 변경 확인에 읽기 전용 바인드 마운트를, 컨테이너 삭제 후 데이터 유지 확인에 named volume을 사용했다.

### Named volume 백업·복원 실습 (2026-11-17)

백업 전 원본 볼륨을 사용하는 컨테이너가 없는 것을 확인했다. 임시 Ubuntu 컨테이너에 원본 볼륨을 읽기 전용으로 연결하고, 아카이브 파일은 저장소 바깥의 `/tmp/mission-backups`에 만들었다.

```bash
docker ps -a --filter volume=mission-data-20261109
mkdir -p /tmp/mission-backups

docker run --rm \
  --mount type=volume,source=mission-data-20261109,target=/data,readonly \
  --mount type=bind,source=/tmp/mission-backups,target=/backup \
  ubuntu tar -czf /backup/mission-data-20261109.tar.gz -C /data .

tar -tzf /tmp/mission-backups/mission-data-20261109.tar.gz
ls -lh /tmp/mission-backups/mission-data-20261109.tar.gz
```

확인 출력:

```text
$ docker ps -a --filter volume=mission-data-20261109
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ tar -tzf /tmp/mission-backups/mission-data-20261109.tar.gz
./
./hello.txt

$ ls -lh /tmp/mission-backups/mission-data-20261109.tar.gz
-rw-r--r-- 1 root root 168 Nov 17 17:09 /tmp/mission-backups/mission-data-20261109.tar.gz
```

새 named volume에 아카이브를 풀고 내용을 확인했다.

```bash
docker volume create mission-data-restore-20261117

docker run --rm \
  --mount type=volume,source=mission-data-restore-20261117,target=/data \
  --mount type=bind,source=/tmp/mission-backups,target=/backup,readonly \
  ubuntu tar -xzf /backup/mission-data-20261109.tar.gz -C /data

docker run --rm \
  --mount type=volume,source=mission-data-restore-20261117,target=/data,readonly \
  ubuntu sh -c 'ls -l /data && cat /data/hello.txt'
```

복원 확인 출력:

```text
total 4
-rw-r--r-- 1 root root 21 Nov  9 13:29 hello.txt
Persistent data test
```

복원한 데이터가 읽히는 것을 확인했다. `/tmp`의 아카이브는 임시 백업이며 저장소에 추가하지 않는다. 실제 운영 데이터는 백업 파일을 별도 영구 저장 위치에도 보관해야 한다.

### 컨테이너 삭제 후 볼륨과 데이터 재확인 (2026-11-17)

```text
$ docker ps -a --filter name=volume-first
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker ps -a --filter name=volume-second
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker volume ls --filter name=mission-data-20261109
DRIVER    VOLUME NAME
local     mission-data-20261109

$ docker run --rm --mount type=volume,source=mission-data-20261109,target=/data,readonly ubuntu cat /data/hello.txt
Persistent data test
```

두 컨테이너가 삭제된 뒤에도 볼륨이 남아 있고, 새 임시 컨테이너에서 기존 파일을 읽을 수 있었다.

## Named volume 백업·복원 절차 예시

다음은 아카이브 기반 백업과 복원 절차 예시이며, 이 미션에서 실제로 실행한 명령은 아니다. 실제 백업에서는 먼저 볼륨에 쓰는 앱을 멈춰 데이터가 일관된 상태가 되게 한다. 예시 아카이브는 `/tmp`에 만들지만, 실제 백업 파일은 별도의 영구 저장 위치에도 복사한다.

```bash
mkdir -p /tmp/mission-backups

# 원본 볼륨을 읽기 전용으로 연결해 gzip tar 아카이브 생성
docker run --rm \
  --mount type=volume,source=mission-data-20261109,target=/data,readonly \
  --mount type=bind,source=/tmp/mission-backups,target=/backup \
  ubuntu tar -czf /backup/mission-data-20261109.tar.gz -C /data .

# 아카이브 안의 파일 목록 확인
tar -tzf /tmp/mission-backups/mission-data-20261109.tar.gz
```

복원은 원본을 덮어쓰지 않도록 새 이름의 빈 볼륨에 수행한다. 아래 이름의 볼륨이 이미 있다면 상태를 확인하고, 필요하면 사용하지 않은 새 이름으로 바꾼다.

```bash
docker volume create mission-data-restore

docker run --rm \
  --mount type=volume,source=mission-data-restore,target=/data \
  --mount type=bind,source=/tmp/mission-backups,target=/backup,readonly \
  ubuntu tar -xzf /backup/mission-data-20261109.tar.gz -C /data

# 복원한 데이터 확인
docker run --rm \
  --mount type=volume,source=mission-data-restore,target=/data,readonly \
  ubuntu sh -c 'ls -la /data && cat /data/hello.txt'
```

백업 아카이브는 공개 GitHub 저장소에 올리지 않는다. 실제 백업·복원을 수행하면 명령과 검증 결과를 별도로 기록한다.

## Docker Compose 단일·다중 서비스

Compose 실습에서는 먼저 웹 서비스 하나를 실행하고, 이후 `toolbox` 서비스를 추가해 두 서비스 간 통신을 확인했다. 저장소 루트의 `compose.yaml`:

```yaml
services:
  web:
    build: .
    image: my-study-web:compose
    ports:
      - "${WEB_PORT:-8080}:80"

  toolbox:
    image: busybox:latest
    command: ["sh", "-c", "while true; do sleep 3600; done"]
```

단일 웹 서비스 실행과 확인:

```bash
docker compose config
docker compose up -d
docker compose ps
curl --max-time 5 -i http://localhost:8080
docker compose logs web
```

웹 컨테이너가 `Up` 상태이고 `8080->80` 포트 연결이 표시됐다. `curl` 응답은 `HTTP/1.1 200 OK`였고 NGINX 로그에 요청이 남았다.

두 서비스 간 통신 확인:

```bash
docker compose exec toolbox wget -qO- http://web:80
```

`toolbox`에서 서비스 이름 `web`로 요청해 HTML을 받았다. 이는 Compose 네트워크에서 서비스 이름으로 통신할 수 있음을 확인한 결과다.

환경 변수로 호스트 포트 변경:

```bash
WEB_PORT=8081 docker compose up -d
docker compose ps
curl --max-time 5 -i http://localhost:8081
docker compose logs --tail=10 web
```

포트가 `8081->80`으로 바뀌었고 `curl`은 HTTP 200을 반환했다.

```bash
docker compose down
docker compose ps
```

두 컨테이너와 Compose 네트워크를 제거한 뒤 `docker compose ps` 결과가 비어 있는 것을 확인했다.

### 환경 변수와 재현 절차

`compose.yaml`의 `"${WEB_PORT:-8080}:80"`은 호스트 포트를 환경 변수로 정한다. `WEB_PORT`가 설정되지 않았거나 빈 값이면 기본 포트 8080을 사용한다. Compose 변수 치환 우선순위는 다음과 같다.

1. 현재 셸의 환경 변수
2. 명령에 지정한 `--env-file` 파일
3. `--env-file`을 지정하지 않았을 때 프로젝트 루트의 `.env` 파일
4. 위에서 값이 정해지지 않으면 `${WEB_PORT:-8080}`의 기본값 8080

이 미션에서는 WSL Bash에서 셸 환경 변수 `WEB_PORT=8081`을 지정해 실행하고, 포트가 `8081->80`으로 바뀌며 HTTP 200 응답이 오는 것을 확인했다.

```bash
# Compose가 해석한 포트 설정 확인
docker compose config

# WSL Bash에서 이번 명령에만 포트 8081 적용
WEB_PORT=8081 docker compose up -d
docker compose ps
curl --max-time 5 -i http://localhost:8081
docker compose down
```

PowerShell에서는 환경 변수 설정 문법이 다르다. PowerShell에서 실행할 때는 다음처럼 설정하고, 사용 후 지운다.

```powershell
$env:WEB_PORT = '8081'
docker compose config
docker compose up -d
Remove-Item Env:WEB_PORT
```

실행 전 선택한 호스트 포트가 사용 중인지 확인하고, 실행 후에는 `docker compose ps`의 포트 표시와 `curl` 응답을 확인한다. 셸 문법과 포트 값까지 기록하면 다른 환경에서도 절차를 재현하기 쉽다.

## 테스트 컨테이너 정리

```bash
docker rm -f volume-second mission-web-bind mission-web-8080 ubuntu-lab priceless_pare
docker ps -a
docker volume ls --filter name=mission-data-20261109
```

이번 실습에서 만든 테스트 컨테이너를 정리했다. 기존 `my-web-server`는 실습 전부터 존재하던 중지 컨테이너이므로 변경하거나 삭제하지 않았다. Named volume `mission-data-20261109`는 컨테이너 정리 후에도 남아 있었다.

## 트러블슈팅

### HTTPS push 인증 실패

- 문제: HTTPS 원격 주소로 push할 때 GitHub가 계정 비밀번호 인증을 거부했다.
- 확인: `Password authentication is not supported for Git operations` 오류가 표시됐다.
- 해결: Ed25519 SSH 키를 생성해 공개 키를 GitHub에 등록하고, SSH 인증을 확인했다. 원격 주소를 `git@github.com:yiel12/my-study.git`로 바꾼 뒤 push에 성공했다.
- 보안: 개인 키와 토큰은 저장소나 기록에 넣지 않았다.

### Compose 이미지 pull 경고

- 문제: Compose 첫 실행에서 `my-study-web:compose` 이미지 pull 권한 경고가 표시됐다.
- 확인: 이어서 저장소의 Dockerfile로 이미지 빌드가 완료됐고 컨테이너가 시작됐다.
- 결과: `docker compose ps`에서 서비스가 `Up`인 것을 확인했고, 웹 요청은 HTTP 200을 반환했다.

### PowerShell에서 WSL 경로 사용

- 문제: PowerShell에서 `/mnt/c/Users/...` 경로로 이동하려 했지만 해당 경로를 찾을 수 없었다.
- 원인: `/mnt/c/...`는 WSL 경로이고 PowerShell은 Windows 경로를 사용한다.
- 해결: PowerShell에서는 `Set-Location -LiteralPath 'C:\Users\STP_7\Desktop\my-study'`를 사용하거나, WSL 터미널로 전환한 뒤 `/mnt/c/Users/Stp_7/Desktop/my-study`로 이동한다.

### 호스트 포트 충돌 진단 (2026-11-17)

8080 포트를 이미 사용 중인 상태에서 같은 포트로 두 번째 컨테이너를 실행해 충돌을 재현했다.

```text
$ docker run --rm -d --name mission-web-conflict -p 8080:80 my-study-web:1.0
docker: Error response from daemon: failed to set up container networking:
Bind for 0.0.0.0:8080 failed: port is already allocated
```

사용 중인 컨테이너를 확인했다.

```text
$ docker ps --filter publish=8080
CONTAINER ID   IMAGE              COMMAND                  STATUS         PORTS                                     NAMES
c5ca26c970c4   my-study-web:1.0   "/docker-entrypoint.…"   Up 22 minutes  0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   mission-web-evidence
```

`ss`에서도 포트가 LISTEN 상태였다. 이 WSL 출력에는 프로세스 PID가 표시되지 않아, Docker의 포트 필터로 소유 컨테이너를 확인했다.

```text
$ ss -ltnp | grep ':8080'
LISTEN 0 4096 *:8080 *:*
```

Docker 컨테이너가 소유한 포트는 PID를 강제 종료하지 않고 소유 컨테이너를 정상 중지한다.

```bash
docker stop mission-web-evidence
docker ps --filter publish=8080
ss -ltnp | grep ':8080' || true
```

중지 뒤 Docker 포트 목록이 비었고 `ss`에서도 8080 결과가 없어 포트가 해제된 것을 확인했다. 일반 Linux 프로세스가 점유한 포트라면 `ss -ltnp 'sport = :8080'`에서 PID를 확인하고 `ps -fp <PID>`로 프로세스를 먼저 식별한다. 직접 실행한 프로그램임을 확인한 경우에만 서비스를 정상 종료하거나 `kill -TERM <PID>`를 사용한다.

### WSL 프로세스의 포트 PID 확인과 정상 종료 (2026-11-17)

WSL에서 임시 Python 서버를 실행해 `ss` 출력에 PID가 어떻게 표시되는지 확인했다.

```text
$ python3 -m http.server 18081 --bind 0.0.0.0 &
Test server PID=6413

$ ss -ltnp | grep ':18081'
LISTEN 0 5 0.0.0.0:18081 0.0.0.0:* users:(("python3",pid=6413,fd=3))

$ ps -fp "$PORT_TEST_PID"
UID     PID   PPID  C STIME TTY   TIME CMD
yiel12  6413  329   0 17:26 pts/0 00:00:00 python3 -m http.server 18081 -
```

같은 숫자 포트 18081로 Docker Desktop 컨테이너 실행도 성공했다. 이 환경에서는 WSL의 Python 리스너와 Docker Desktop의 공개 포트가 충돌하지 않았다. 따라서 서로 다른 네트워크 경계에서 포트 충돌 여부를 확인해야 한다.

```bash
kill -TERM "$PORT_TEST_PID"
sleep 1
ps -fp "$PORT_TEST_PID" || true
ss -ltnp | grep ':18081' || echo 'Port 18081 is free in WSL'
docker rm -f mission-port-conflict-18081
```

```text
$ ps -fp "$PORT_TEST_PID"
UID          PID    PPID  C STIME TTY          TIME CMD
yiel12@STP7:/mnt/c/Users/Stp_7/Desktop/my-study$

$ ss -ltnp | grep ':18081' || echo 'Port 18081 is free in WSL'
Port 18081 is free in WSL

$ docker rm -f mission-port-conflict-18081
mission-port-conflict-18081
```

일반 WSL 프로세스는 `ss`의 PID를 `ps -fp <PID>`로 먼저 식별한 뒤, 내가 실행한 프로세스임을 확인하고 `kill -TERM <PID>`로 정상 종료한다. Docker가 소유한 포트라면 `docker ps --filter publish=<포트>`로 컨테이너를 찾고 `docker stop <컨테이너>`를 사용한다.

### WSL에서 Docker 명령을 찾지 못한 문제 (2026-11-17)

- 문제: WSL에서 `docker info`를 실행했을 때 Docker CLI를 찾지 못했다.
- 확인 출력:

```text
The command 'docker' could not be found in this WSL 2 distro.
We recommend to activate the WSL integration in Docker Desktop settings.
```

- 조치: Docker Desktop의 WSL Integration 설정에서 Ubuntu를 켜고 적용했다.
- 결과: 같은 WSL 터미널에서 `docker info`가 동작했고 Client·Server 버전 `29.9.3`과 Compose `v5.7.0`을 확인했다.

### WSL에서 GitHub SSH에 연결할 수 없었던 문제 (2026-11-17)

- 문제: README 커밋은 로컬에 있었지만 WSL의 SSH와 HTTPS 네트워크 경로가 GitHub에 도달하지 못했다.
- WSL SSH 확인:

```text
$ ssh -T git@github.com
ssh: connect to host github.com port 22: No route to host

$ ssh -T -p 443 git@ssh.github.com
ssh: connect to host ssh.github.com port 443: No route to host
```

- WSL HTTPS 확인:

```text
$ curl -I --max-time 10 https://github.com
curl: (7) Failed to connect to github.com port 443: Could not connect to server
```

- Windows PowerShell에서는 `Test-NetConnection github.com -Port 443`의 `TcpTestSucceeded`가 `True`였고, Git Credential Manager가 설정돼 있음을 확인했다.
- 해결: Windows PowerShell에서 HTTPS 주소로 push하고 원격 추적 정보를 새로 받아왔다.

```text
$ git push https://github.com/yiel12/my-study.git main:main
To https://github.com/yiel12/my-study
   2f260b2..67cdd30  main -> main

$ git fetch https://github.com/yiel12/my-study.git main:refs/remotes/origin/main
2f260b2..67cdd30  main -> origin/main

$ git status --short --branch
## main...origin/main
```

- 참고: WSL의 `ahead 1`은 HTTPS 직접 push 뒤 로컬 `origin/main` 추적 정보가 갱신되지 않아 보였던 상태였다. Fetch로 추적 정보를 갱신한 뒤 동기화를 확인했다.

### `touch -v` 옵션 오류

- 문제: `touch -v note.txt`에서 `unexpected argument '-v'` 오류가 났다.
- 원인: 사용 중인 `touch` 명령은 `-v` 옵션을 지원하지 않는다.
- 해결: `touch note.txt`처럼 옵션 없이 사용하거나, 이번 실습처럼 `printf '내용\n' > note.txt`로 파일을 생성했다.

## 미션 원리 정리

- 이미지와 컨테이너의 차이: 이미지는 컨테이너를 만드는 읽기 전용 템플릿이고, 컨테이너는 이미지로 실행한 인스턴스다. 컨테이너를 삭제해도 별도 볼륨의 데이터는 남을 수 있다.
- 절대 경로와 상대 경로: 절대 경로는 `/`부터 위치를 지정하고, 상대 경로는 현재 작업 폴더를 기준으로 지정한다.
- 권한 숫자 표기: `r=4`, `w=2`, `x=1`을 더해 소유자·그룹·기타 사용자 순서로 쓴다. 파일 `644`는 소유자가 읽고 쓸 수 있고 나머지는 읽을 수 있다. 디렉터리 `755`는 소유자가 전체 권한을 가지며 나머지는 읽고 접근할 수 있다.
- 호스트 포트 충돌 진단 순서: 먼저 `docker ps`에서 사용 중인 포트 매핑을 확인하고, 필요하면 `ss -ltnp`로 호스트 포트를 점유한 프로세스를 찾는다. 해당 서비스를 정리하거나 다른 호스트 포트를 선택한 뒤 다시 접속을 확인한다.

### 호스트 경로와 컨테이너 경로 선택 기준

- 현재 작업 폴더를 기준으로 빠르게 입력할 때는 상대 경로를 쓸 수 있다. 예를 들어 저장소 루트에서 `index.html`은 상대 경로다.
- 스크립트나 다른 작업 폴더에서도 같은 파일을 가리켜야 할 때는 절대 경로를 사용하면 현재 위치에 따른 혼동을 줄일 수 있다.
- Dockerfile의 `COPY` 원본 경로는 호스트의 임의 경로가 아니라 Docker 빌드 문맥 안의 상대 경로다. 이 프로젝트는 저장소 루트에서 `docker build .`을 실행하므로 `COPY index.html ...`로 지정한다.
- 바인드 마운트의 `source`는 호스트 파일 경로이고 `target`은 컨테이너 안의 경로다. 두 경로는 서로 다른 파일 시스템의 위치이므로 바꿔 쓰면 안 된다.
- WSL에서 실행할 때는 호스트 파일을 `/mnt/c/...` 또는 저장소 기준 `$(pwd)`로 지정하고, 컨테이너 안의 경로는 `/usr/share/nginx/html/index.html`처럼 컨테이너 경로로 지정한다. 마운트 원본 파일이 실제로 존재하는지도 확인한다.

실습에서 사용한 경로 연결:

```bash
--mount type=bind,source="$(pwd)/index.html",target=/usr/share/nginx/html/index.html,readonly
```

확인 결과:

```text
bind destination=/usr/share/nginx/html/index.html read-write=false
```

여기서 `$(pwd)/index.html`은 호스트의 저장소 파일이고, `/usr/share/nginx/html/index.html`은 컨테이너 안에서 NGINX가 읽는 파일이다.
