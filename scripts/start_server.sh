#!/bin/bash

# scripts 폴더에서 상위 폴더(루트)로 이동
cd "$(dirname "$0")/.."

echo "🚀 서버를 시작할게! (포트 8080)"
echo "🛑 서버를 끄려면 터미널에서 Ctrl+C를 눌러."

# 포그라운드에서 바로 실행 (백그라운드 처리 기호 & 와 nohup 제거)
python3 -m http.server 8080 --bind 0.0.0.0