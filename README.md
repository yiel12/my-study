# 개발 워크스테이션 미션 수행 기록

## 미션 목표

터미널, Docker, Git/GitHub를 사용해 재현 가능한 개발 환경을 구성하고, 각 단계의 명령과 검증 결과를 기록한다.

## 수행 체크리스트

- [ ] 터미널 기본 명령과 경로 확인
- [ ] 파일 및 디렉터리 권한 확인·변경
- [ ] Docker 버전과 엔진 상태 확인
- [ ] `hello-world`와 Ubuntu 컨테이너 실행
- [ ] 컨테이너 `attach`와 `exec` 차이 확인
- [ ] Dockerfile 작성 및 커스텀 웹 서버 이미지 빌드
- [ ] 포트 매핑 후 브라우저 또는 `curl`로 접속 확인
- [ ] 바인드 마운트 파일 변경 반영 확인
- [ ] 컨테이너 삭제 후 named volume 데이터 유지 확인
- [ ] Git 설정과 VS Code/GitHub 연동 확인
- [ ] 보너스: Compose 단일 서비스 실행
- [ ] 보너스: Compose 웹+보조 서비스 통신 확인
- [ ] 보너스: `up`, `down`, `ps`, `logs` 실행 기록
- [ ] 보너스: 환경 변수 적용
- [ ] 보너스: GitHub SSH 인증 확인

## 실행 환경

- OS:
- 셸/터미널:
- Docker 버전:
- Git 버전:

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