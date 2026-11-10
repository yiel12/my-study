# 개발 워크스테이션 미션 수행 기록

## 미션 목표

터미널, Docker, Git/GitHub를 사용해 재현 가능한 개발 환경을 구성하고, 각 단계의 명령과 검증 결과를 기록한다.

## 수행 체크리스트

- [X] 터미널 기본 명령과 경로 확인
- [X] 파일 및 디렉터리 권한 확인·변경
- [X] Docker 버전과 엔진 상태 확인
- [X] `hello-world`와 Ubuntu 컨테이너 실행
- [X] 컨테이너 `attach`와 `exec` 차이 확인
- [X] Dockerfile 작성 및 커스텀 웹 서버 이미지 빌드
- [X] 포트 매핑 후 브라우저 또는 `curl`로 접속 확인
- [X] 바인드 마운트 파일 변경 반영 확인
- [X] 컨테이너 삭제 후 named volume 데이터 유지 확인
- [X] Git 설정과 VS Code/GitHub 연동 확인
- [X] 보너스: Compose 단일 서비스 실행
- [X] 보너스: Compose 웹+보조 서비스 통신 확인
- [X] 보너스: `up`, `down`, `ps`, `logs` 실행 기록
- [X] 보너스: 환경 변수 적용
- [X] 보너스: GitHub SSH 인증 확인

## 실행 환경

- OS: Ubuntu 26.04.1 LTS (WSL)
- 셸/터미널: WSL Bash
- Docker 버전: Docker version 29.9.2 (build a82e528)
- Git 버전: 2.53.0

## 수행 로그

### 0. 저장소 기준 상태 확인

- 확인 날짜: 2026-11-09
- 브랜치: `main`, `origin/main`과 동기화
- 원격 저장소: `https://github.com/yiel12/my-study.git`
- 현재 추적 파일: `command-history.txt`, `index.html`
- 미션 원본 및 참고 문서는 미추적 상태이며, 이 저장소 기록에는 추가하지 않는다.
- 이 기록은 검증한 실제 출력과 증거만 이어서 추가한다.

## 검증 증거

단계별 명령과 핵심 출력을 여기에 기록한다. 민감정보는 포함하지 않는다.

## 트러블슈팅

각 문제마다 `문제 → 원인 가설 → 확인 → 해결 또는 대안` 순서로 기록한다.

## 미션 원리 정리

- 이미지와 컨테이너의 차이:
- 포트 매핑이 필요한 이유:
- 절대 경로와 상대 경로:
- 권한 숫자 표기:
- 볼륨으로 데이터를 유지하는 방법:
- 호스트 포트 충돌 진단 순서:


## GitHub 기록 추가

- [x] 보너스: GitHub SSH 인증 확인

### GitHub SSH 설정 및 README 게시

- `~/.ssh` 폴더가 없음을 확인하고 Ed25519 키를 생성했다.
- 공개키를 GitHub 계정에 등록했다. 키 내용과 암호는 기록하지 않는다.
- `ssh -T git@github.com` 결과: `Hi yiel12! You've successfully authenticated, but GitHub does not provide shell access.`
- HTTPS 주소로 push했을 때 비밀번호 인증이 지원되지 않아 실패했다.
- 원격 주소를 SSH 방식으로 변경하고 push를 다시 실행해 성공했다.
- 원격 주소: `git@github.com:yiel12/my-study.git`
- README 첫 커밋 `25ce4d2`가 `main` 브랜치에 게시됐다.

#### 트러블슈팅: HTTPS push 인증 실패

- 문제: GitHub가 HTTPS push에서 비밀번호 인증을 거부했다.
- 원인: 원격 주소가 HTTPS였고, GitHub는 Git 작업의 계정 비밀번호 인증을 지원하지 않는다.
- 확인: 인증 오류에 `Password authentication is not supported for Git operations`가 표시됐다.
- 해결: SSH 키를 등록하고 연결을 확인한 뒤 원격 주소를 SSH로 바꾸어 push했다.

### Docker 설치 및 엔진 상태 확인

```bash
docker --version
# Docker version 29.9.2, build a82e528

docker info --format 'Server={{.ServerVersion}} Containers={{.Containers}} Running={{.ContainersRunning}} Stopped={{.ContainersStopped}} Images={{.Images}}'
# Server=29.9.2 Containers=1 Running=0 Stopped=1 Images=3
```

Docker CLI 버전과 엔진 응답을 확인했다. 점검 시 실행 중인 컨테이너는 0개, 중지된 컨테이너는 1개, 이미지는 3개였다.

### Docker `hello-world` 실행

```text
$ docker run hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

출력에서 Docker 데몬이 `hello-world` 이미지를 내려받고, 컨테이너를 생성해 실행한 것을 확인했다.

- [x] `hello-world`와 Ubuntu 컨테이너 실행
- [x] Ubuntu에서 `attach`, `exec`, `exit` 차이 확인

### Ubuntu 컨테이너와 셸 연결 방식 확인

```bash
docker run -dit --name ubuntu-lab ubuntu bash
docker ps --filter name=ubuntu-lab
```

컨테이너 `ubuntu-lab`이 `Up` 상태인 것을 확인했다.

```bash
docker attach ubuntu-lab
```

컨테이너 안에서 `pwd`, `ls`, `echo`를 실행했다. Ctrl+P, Ctrl+Q로 연결을 분리한 뒤 `docker ps`에서 컨테이너가 계속 `Up` 상태인 것을 확인했다.

```bash
docker exec -it ubuntu-lab bash
pwd
ls
echo "hello from exec shell"
exit
docker ps --filter name=ubuntu-lab
```

`exec`로 연 별도 Bash에서 `exit`한 뒤에도 주 컨테이너는 `Up` 상태였다.

```bash
docker attach ubuntu-lab
echo "exiting the main shell"
exit
docker ps -a --filter name=ubuntu-lab
```

주 Bash에서 `exit`한 뒤 컨테이너 상태가 `Exited (0)`으로 바뀌었다.

```bash
docker start -ai ubuntu-lab
pwd
/
ls
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
echo "Ubuntu commands verified"
Ubuntu commands verified
exit
```

`attach`는 컨테이너의 주 프로세스 입출력에 연결한다. 연결만 분리하면 주 프로세스가 계속 실행되고, 주 Bash에서 `exit`하면 컨테이너가 종료된다. `exec`는 실행 중인 컨테이너에 별도 프로세스(여기서는 Bash)를 추가하며, 그 Bash에서 `exit`해도 주 프로세스는 계속 실행된다.

- [x] Docker 이미지/컨테이너 목록, 로그, 통계 확인

### Docker 이미지·컨테이너 운영 확인

```text
$ docker images
hello-world:latest
nginx:latest
ubuntu:latest
```

확인 시 이미지 3개가 있었다.

```text
$ docker ps -a
ubuntu-lab      Exited (0)
priceless_pare  Exited (0)   # hello-world
my-web-server   Exited (137) # 기존 컨테이너, 이번 실습에서 변경하지 않음
```

```bash
docker logs priceless_pare
```

로그에 `Hello from Docker!`가 출력되어 `hello-world` 컨테이너의 실행 결과를 확인했다.

```text
$ docker stats --no-stream ubuntu-lab
CPU: 0.00%
Memory: 2.242MiB / 7.52GiB (0.03%)
Network I/O: 1.17kB / 126B
Block I/O: 0B / 0B
Processes: 1
```

```bash
docker stop ubuntu-lab
docker ps -a --filter name=ubuntu-lab
```

`ubuntu-lab`은 중지됐으며 최종 상태는 `Exited (137)`이었다. 기존 `my-web-server` 컨테이너는 그대로 두었다.

### 터미널 기본 조작 및 경로 확인

작업 폴더: `/home/yiel12/workstation-mission-practice`

```bash
pwd
# /home/yiel12/workstation-mission-practice

whoami
# yiel12

mkdir terminal-demo
touch terminal-demo/note.txt
printf 'Hello from the terminal\n' > terminal-demo/note.txt

cat terminal-demo/note.txt
# Hello from the terminal

cp terminal-demo/note.txt note-copy.txt
mv note-copy.txt note-renamed.txt
ls -la
rm note-renamed.txt
ls -la

cat /home/yiel12/workstation-mission-practice/terminal-demo/note.txt
# Hello from the terminal
```

`terminal-demo/note.txt`는 현재 위치 기준 상대 경로이고, `/home/yiel12/.../note.txt`는 루트(`/`)부터 지정한 절대 경로다. 두 경로로 같은 파일 내용을 확인했다. `ls -la`로 숨김 항목을 포함한 목록도 확인했다.

### 파일·디렉터리 권한 실습

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

권한 숫자는 소유자·그룹·기타 사용자 순서로 읽는다. `r=4`, `w=2`, `x=1`이며 숫자를 더해 표기한다. 예를 들어 `644`는 소유자가 읽기·쓰기(6), 그룹과 기타 사용자는 읽기(4)만 가능하다. 디렉터리의 `x`는 내부 항목에 접근할 수 있는 권한이다.


- [x] Dockerfile 작성 및 커스텀 웹 서버 이미지 빌드

### 커스텀 NGINX 이미지 빌드

- 베이스 이미지: `nginx:latest`
- 커스텀 내용: 저장소의 `index.html`을 NGINX 기본 웹 폴더로 복사
- `EXPOSE 80`으로 컨테이너가 사용하는 웹 포트를 표시
- `.dockerignore`로 빌드 문맥을 제한했으며, 빌드 출력에서 문맥 크기 292B를 확인

```bash
docker build -t my-study-web:1.0 .
```

```text
[+] Building 4.5s (7/7) FINISHED
[2/2] COPY index.html /usr/share/nginx/html/index.html
naming to docker.io/library/my-study-web:1.0
```


- [x] 포트 매핑 후 `curl`로 접속 확인

### 커스텀 웹 서버 실행 및 포트 매핑

```bash
docker run -d --name mission-web-8080 -p 8080:80 my-study-web:1.0
docker ps --filter name=mission-web-8080
```

컨테이너 상태에서 `0.0.0.0:8080->80/tcp`가 표시됐다.

```bash
curl --max-time 5 -i http://localhost:8080
```

```text
HTTP/1.1 200 OK
Server: nginx/1.31.8
Content-Type: text/html

<title>나의 첫 웹 서버</title>
<h1>안녕, 도커! 🐳</h1>
<p>내가 만든 HTML 파일이 웹 서버에서 돌아가고 있어요!</p>
```

호스트 포트 `8080` 요청이 컨테이너 포트 `80`으로 전달되고, NGINX가 저장소의 `index.html`을 반환했다.

- [x] 바인드 마운트 파일 변경 반영 확인

### 바인드 마운트와 호스트 파일 변경 반영

기존 `mission-web-8080`을 중지하고, 저장소의 `index.html`을 NGINX 컨테이너 경로에 읽기 전용으로 연결했다.

```bash
docker stop mission-web-8080
docker run -d --name mission-web-bind -p 8080:80 --mount type=bind,source="$(pwd)/index.html",target=/usr/share/nginx/html/index.html,readonly my-study-web:1.0
docker inspect --format '{{range .Mounts}}{{.Type}} destination={{.Destination}} read-write={{.RW}}{{end}}' mission-web-bind
```

```text
bind destination=/usr/share/nginx/html/index.html read-write=false
```

호스트 파일을 수정하기 전 `curl http://localhost:8080`에서 기존 페이지와 `HTTP/1.1 200 OK`를 확인했다. 호스트의 `index.html`을 수정하고 다시 확인하자 새 내용이 즉시 표시됐다. 이미지를 다시 빌드하지 않았다.

```html
<h1>안녕, 바인드 마운트!</h1>
<p>호스트 파일 수정이 컨테이너에 바로 반영됐습니다.</p>
```

- [x] 컨테이너 삭제 후 named volume 데이터 유지 확인

### Named volume 데이터 영속성 확인

```bash
docker volume create mission-data-20261109
docker run -d --name volume-first --mount type=volume,source=mission-data-20261109,target=/data ubuntu sleep infinity
docker exec volume-first sh -c 'echo "Persistent data test" > /data/hello.txt && cat /data/hello.txt'
```

첫 번째 컨테이너의 출력:

```text
Persistent data test
```

첫 번째 컨테이너를 삭제한 뒤 같은 볼륨을 새 컨테이너에 연결했다.

```bash
docker rm -f volume-first
docker run -d --name volume-second --mount type=volume,source=mission-data-20261109,target=/data ubuntu sleep infinity
docker ps -a --filter name=volume-first
docker exec volume-second cat /data/hello.txt
```

첫 번째 컨테이너 목록에는 결과가 없었고, 두 번째 컨테이너에서 다음 데이터를 읽었다.

```text
Persistent data test
```

컨테이너를 삭제해도 named volume은 별도로 남아 데이터를 유지했다.


- [x] 이번 미션 테스트 컨테이너 정리

### 테스트 컨테이너 정리 및 Compose 확인

```bash
docker rm -f volume-second mission-web-bind mission-web-8080 ubuntu-lab priceless_pare
docker ps -a
docker volume ls --filter name=mission-data-20261109
docker compose version
```

이번 미션의 테스트 컨테이너 5개를 정리했다. 기존 `my-web-server`는 7일 전에 생성된 중지 상태의 컨테이너로, 이번 실습에서 변경하거나 삭제하지 않았다. named volume `mission-data-20261109`는 컨테이너 정리 후에도 목록에 남아 있다.

Compose 버전: `Docker Compose version v5.6.1`

### Compose 단일·다중 서비스 실습

저장소 루트에 `compose.yaml`을 작성했다. 웹 서비스는 Dockerfile에서 빌드하고, 호스트 포트는 `WEB_PORT` 환경 변수로 지정한다. 기본값은 8080이다.

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

실습 및 확인한 명령:

```bash
docker compose config
docker compose up -d
docker compose ps
curl --max-time 5 -i http://localhost:8080
docker compose logs web
docker compose exec toolbox wget -qO- http://web:80
WEB_PORT=8081 docker compose up -d
docker compose ps
curl --max-time 5 -i http://localhost:8081
docker compose logs --tail=10 web
docker compose down
docker compose ps
```

- 단일 웹 서비스 실행 시 `docker compose ps`에서 `my-study-web-1`의 상태가 `Up`, 포트가 `8080->80`으로 표시됐다.
- `curl http://localhost:8080` 응답은 `HTTP/1.1 200 OK`였다.
- `docker compose logs web`에서 NGINX 시작 로그와 HTTP 200 요청 로그를 확인했다.
- `toolbox`에서 `wget -qO- http://web:80`을 실행해 HTML을 받았다. Compose 내부 네트워크에서 서비스 이름 `web`으로 통신됨을 확인했다.
- `WEB_PORT=8081`로 실행한 뒤 포트가 `8081->80`으로 바뀌었고, `curl http://localhost:8081`도 HTTP 200을 반환했다.
- `docker compose down`으로 두 컨테이너와 네트워크를 제거했다. 이후 `docker compose ps` 결과는 비어 있었다.

#### 트러블슈팅: Compose 이미지 pull 경고

- 문제: 첫 실행에서 `Image my-study-web:compose pull access denied` 경고가 표시됐다.
- 확인: Compose가 이어서 저장소의 Dockerfile로 이미지를 빌드했고, 컨테이너가 `Started` 상태가 됐다.
- 해결: 원격 이미지가 없어도 `build: .` 설정으로 로컬 빌드가 진행되는 것을 확인했다. 웹 요청도 HTTP 200으로 응답했다.


