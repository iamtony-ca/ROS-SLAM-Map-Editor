#!/bin/bash

echo "🚀 오프라인 구동을 위한 라이브러리 다운로드를 시작합니다..."

# 1. 폴더 구조 생성
mkdir -p libs/css libs/js libs/fonts

# 2. CSS 다운로드
echo "⬇️ CSS 파일 다운로드 중..."
wget -q -O libs/css/bootstrap.min.css https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css
wget -q -O libs/css/font-awesome.min.css https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css

# 3. JS 다운로드
echo "⬇️ JavaScript 파일 다운로드 중..."
wget -q -O libs/js/jquery-3.4.1.min.js https://code.jquery.com/jquery-3.4.1.min.js
wget -q -O libs/js/bootstrap.bundle.min.js https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.bundle.min.js
wget -q -O libs/js/js-yaml.min.js https://cdn.jsdelivr.net/npm/js-yaml@4.1.0/dist/js-yaml.min.js

# 4. Font Awesome 폰트 파일 다운로드 (아이콘 깨짐 방지 핵심!)
echo "⬇️ Font Awesome 폰트 파일 다운로드 중..."
wget -q -O libs/fonts/fontawesome-webfont.eot https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/fonts/fontawesome-webfont.eot
wget -q -O libs/fonts/fontawesome-webfont.woff2 https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/fonts/fontawesome-webfont.woff2
wget -q -O libs/fonts/fontawesome-webfont.woff https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/fonts/fontawesome-webfont.woff
wget -q -O libs/fonts/fontawesome-webfont.ttf https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/fonts/fontawesome-webfont.ttf
wget -q -O libs/fonts/fontawesome-webfont.svg https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/fonts/fontawesome-webfont.svg

echo "✅ 모든 다운로드가 완료되었습니다! 'libs' 폴더를 확인하세요."