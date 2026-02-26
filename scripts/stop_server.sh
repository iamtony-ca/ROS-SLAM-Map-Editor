#!/bin/bash

echo "🛑 8080 포트의 파이썬 서버를 종료할게."
pkill -f "python3 -m http.server 8080"
echo "✅ 종료 완료!"