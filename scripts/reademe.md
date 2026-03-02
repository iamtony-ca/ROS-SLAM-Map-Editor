### 🛠️ 사용 방법

1. **실행 권한 부여하기:**
터미널을 열고 스크립트가 있는 폴더로 가서 실행 권한을 줘. 이건 처음 한 번만 하면 돼.
```bash
chmod +x manage_server.sh

```


2. **서버 켜기:**
```bash
./manage_server.sh start

```


이 명령어를 치면 백그라운드에서 서버가 돌기 시작해. 터미널 창을 닫아도 서버는 계속 살아있을 거야.
3. **서버 끄기:**
```bash
./manage_server.sh stop

```


4. **서버 재시작:**
```bash
./manage_server.sh restart

```


1. **실행 권한 부여하기:**
```bash
chmod +x scripts/start_server.sh scripts/stop_server.sh
```

2. **서버 켜기:**
```bash
./start_server.sh

```

3. **서버 끄기:**
```bash
./stop_server.sh

```

4. **접속 Address**
chrome, firefox 등에서 아래 입력.
```
http://localhost:8080/editor.html

```
or  
```
http://127.0.0.1:8080/editor.html
```

**외부 같은 Network 에서 접속시**
```
server ip address:8080/editor.html
```


# check if port is in use or not
```
lsof -i :8080
```
or
```
ss -tuln | grep 8080
```