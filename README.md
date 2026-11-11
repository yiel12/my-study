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

## Docker 엔진 확인 및 기본 컨테이너

```bash
docker --version
# Docker version 29.9.2, build a82e528

docker info --format 'Server={{.ServerVersion}} Containers={{.Containers}} Running={{.ContainersRunning}} Stopped={{.ContainersStopped}} Images={{.Images}}'
# Server=29.9.2 Containers=1 Running=0 Stopped=1 Images=3
```

`hello-world` 이미지를 실행해 Docker 데몬이 이미지로 컨테이너를 만들고 실행하는 것을 확인했다.

```bash
docker run hello-world
```

출력에는 `Hello from Docker!`와 설치가 정상 동작한다는 안내가 표시됐다.

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

## 네트워크 네임스페이스와 포트 매핑

컨테이너는 자체 네트워크 네임스페이스를 사용해 호스트와 분리된 네트워크 인터페이스, IP 주소, 경로, 포트 공간을 가진다. 따라서 컨테이너 안의 80번 포트와 호스트의 `localhost:80`은 같은 주소가 아니며, 호스트 요청이 컨테이너로 자동 전달되지 않는다.

Docker의 `-p 8080:80` 설정은 호스트의 8080번 포트로 들어온 요청을 컨테이너 IP의 80번 포트로 전달(포트 포워딩)한다. 같은 Docker 네트워크 안의 컨테이너는 포트를 호스트에 공개하지 않아도 서비스 이름으로 통신할 수 있다. 호스트나 외부에서 접속할 서비스를 공개할 때 포트 매핑을 사용한다.

```bash
docker run -d --name mission-web-8080 -p 8080:80 my-study-web:1.0
docker ps --filter name=mission-web-8080
curl --max-time 5 -i http://localhost:8080
```

컨테이너 상태에 `0.0.0.0:8080->80/tcp`가 표시됐고, `curl`은 `HTTP/1.1 200 OK`와 저장소의 HTML을 반환했다.

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

## 미션 원리 정리

- 이미지와 컨테이너의 차이: 이미지는 컨테이너를 만드는 읽기 전용 템플릿이고, 컨테이너는 이미지로 실행한 인스턴스다. 컨테이너를 삭제해도 별도 볼륨의 데이터는 남을 수 있다.
- 절대 경로와 상대 경로: 절대 경로는 `/`부터 위치를 지정하고, 상대 경로는 현재 작업 폴더를 기준으로 지정한다.
- 권한 숫자 표기: `r=4`, `w=2`, `x=1`을 더해 소유자·그룹·기타 사용자 순서로 쓴다. 파일 `644`는 소유자가 읽고 쓸 수 있고 나머지는 읽을 수 있다. 디렉터리 `755`는 소유자가 전체 권한을 가지며 나머지는 읽고 접근할 수 있다.
- 호스트 포트 충돌 진단 순서: 먼저 `docker ps`에서 사용 중인 포트 매핑을 확인하고, 필요하면 `ss -ltnp`로 호스트 포트를 점유한 프로세스를 찾는다. 해당 서비스를 정리하거나 다른 호스트 포트를 선택한 뒤 다시 접속을 확인한다.