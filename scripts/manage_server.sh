#!/bin/bash

# 설정 변수
PORT=8080
BIND_IP="0.0.0.0"

# 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # scripts 폴더 경로
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"                  # 최상위(ROS-SLAM-Map-Editor) 경로
PID_FILE="$SCRIPT_DIR/map_editor_server.pid"
LOG_FILE="$SCRIPT_DIR/server.log"

start_server() {
    # 프로세스가 살아있는지 확인
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "✅ 서버가 이미 실행 중이야! (PID: $(cat "$PID_FILE"))"
        echo "👉 접속 주소: http://로봇IP주소:$PORT/index.html"
    else
        echo "🚀 서버를 시작하는 중... (포트: $PORT, 바인딩: $BIND_IP)"
        
        # 중요: 최상위 폴더로 이동한 뒤에 파이썬 서버를 실행!
        cd "$ROOT_DIR" || exit
        
        # nohup으로 백그라운드 실행 후 로그는 scripts 폴더의 server.log에 저장
        nohup python3 -m http.server $PORT --bind $BIND_IP > "$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"
        echo "✅ 서버가 백그라운드에서 실행되었어."
        echo "📝 로그를 보려면 'tail -f $LOG_FILE'를 입력해."
    fi
}

stop_server() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "🛑 서버를 종료하는 중... (PID: $(cat "$PID_FILE"))"
        kill $(cat "$PID_FILE")
        rm "$PID_FILE"
        echo "✅ 서버가 정상적으로 종료되었어."
    else
        echo "⚠️ 실행 중인 서버 프로세스를 찾을 수 없어."
        fuser -k $PORT/tcp 2>/dev/null
    fi
}

case "$1" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    restart)
        stop_server
        sleep 1
        start_server
        ;;
    *)
        echo "사용법: $0 {start|stop|restart}"
        exit 1
esac