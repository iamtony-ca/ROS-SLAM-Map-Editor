Nav2 Jazzy와 HTML/JS 맵 에디터 전문가로서, 해당 코드를 수정하여 원하시는 두 가지 기능을 구현하는 방법을 알려드리겠습니다.

제공해주신 `editor.html` 코드는 매우 잘 작성된 단일 파일 에디터입니다. 아래의 수정을 적용하면 **Keep-out 영역의 PGM 픽셀 값을 160으로 설정**하고, **YAML 저장 시 Origin 포맷을 한 줄로** 맞출 수 있습니다.

---

### 1. Keep-out 값을 0(검은색)에서 160(회색)으로 변경

이 수정은 두 단계가 필요합니다. 첫째는 **그리는 값(Painting Value)**을 160으로 바꾸는 것이고, 둘째는 **화면 표시(Visualizer)**가 160도 빨간색(Keep-out 색상)으로 인식하게 하는 것입니다.

코드 내 `<script>` 태그 안에서 다음 부분들을 찾아 수정하세요.

#### 수정 A: 그리기 로직 (Painting Primitives)

`paintAt`, `drawThickLine`, `drawFilledRect` 함수 내에서 `tool === 'mask'`일 때의 값을 `0`에서 `160`으로 변경합니다.

**1. `paintAt` 함수 수정 (약 570번째 줄 근처)**

```javascript
// [이전]
// paintBuffer('mask', mask, w, h, mx, my, rad, 0); 

// [수정 후] 0 -> 160 변경
paintBuffer('mask', mask, w, h, mx, my, rad, 160);

```

**2. `drawThickLine` 함수 수정 (약 615번째 줄 근처)**

```javascript
// [이전]
// else if(tool==='mask')  paintBuffer('mask', mask,       w,h, mx,my, rad, 0);

// [수정 후] 0 -> 160 변경
else if(tool==='mask')  paintBuffer('mask', mask,       w,h, mx,my, rad, 160);

```

**3. `drawFilledRect` 함수 수정 (약 645번째 줄 근처)**

```javascript
// [이전]
// const maskVal = (tool==='mask')  ? 0 : (tool==='erase' ? 255    : null);

// [수정 후] 0 -> 160 변경
const maskVal = (tool==='mask')  ? 160 : (tool==='erase' ? 255    : null);

```

#### 수정 B: 화면 표시 로직 (Visualizer)

기존 코드는 20 이하의 값만 Keep-out으로 간주하여 화면에 표시합니다. 이를 수정하지 않으면, 160으로 칠했을 때 데이터는 바뀌지만 화면에는 아무것도 보이지 않습니다.

**`redrawMask` 함수 수정 (약 770번째 줄 근처)**

```javascript
function redrawMask(){
  // ... (생략)
  for(let i=0;i<w*h;i++){
    const m = mask[i];       // 0..255

    // [이전] 20 이하는 검은색에 가까우므로 Keep-out으로 표시
    // const isKO = (m <= 20);

    // [수정 후] 255(완전 흰색/Free)가 아니면 모두 Keep-out으로 표시
    const isKO = (m !== 255); 
    
    img.data[4*i+0] = isKO ? 255 : 0;
    // ... (생략)
  }
  // ...
}

```

---

### 2. YAML 다운로드 시 Origin 포맷 수정

`js-yaml` 라이브러리는 기본적으로 배열을 여러 줄로 나누는 경향이 있습니다. 이를 해결하기 위해 `lineWidth` 옵션을 늘리고, 출력된 문자열을 정규식(Regex)으로 한 번 더 다듬어서 `[x, y, z]` 형태로 강제 변환합니다.

코드 하단의 **`Download` 관련 로직**을 수정합니다.

**1. YAML 포맷팅 헬퍼 함수 추가**
스크립트 하단 `dlText` 함수 근처에 아래 헬퍼 함수를 추가하거나, 기존 `jsyaml.dump`를 호출하는 곳을 직접 수정합니다. 가장 깔끔한 방법은 `jsyaml.dump` 호출부를 감싸는 것입니다.

**2. `buildUpdatedYaml` 함수 수정 (약 860번째 줄)**

```javascript
  function buildUpdatedYaml(imageName){
    if(!yamlObj) return '';
    const y = Object.assign({}, yamlObj, { image: imageName });
    
    // [수정 후] lineWidth를 늘려서 한 줄 출력을 유도하고, 정규식으로 origin 포맷 강제
    let yamlStr = jsyaml.dump(y, { lineWidth: 1000 });
    
    // origin: [ ... ] 형태로 강제 변환하는 정규식
    yamlStr = yamlStr.replace(/origin:\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)/g, 'origin: [$1, $2, $3]');
    
    return yamlStr;
  }

```

**3. `$('#btnDownloadMask').on('click', ...)` 부분 수정 (약 878번째 줄)**
Keep-out 마스크 다운로드 버튼 로직도 동일하게 적용합니다.

```javascript
  $('#btnDownloadMask').on('click', ()=>{
    if(!pgm || !yamlObj || !mask){ alert('Load YAML and PGM first.'); return; }
    // ... (기존 코드 유지) ...
    const outMaskYaml = base + '_keepout.yaml';
    const y = Object.assign({}, yamlObj, { image: outMaskPgm });
    
    // [수정 부분 시작]
    let yamlStr = jsyaml.dump(y, { lineWidth: 1000 });
    // origin 포맷 강제 변환
    yamlStr = yamlStr.replace(/origin:\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)/g, 'origin: [$1, $2, $3]');
    
    dlBytes(maskBytes, outMaskPgm, 'image/x-portable-graymap');
    dlText(yamlStr, outMaskYaml, 'text/yaml'); // 수정된 yamlStr 사용
    // [수정 부분 끝]
  });

```

### 요약

1. **값 160 설정:** `paintBuffer`, `drawFilledRect` 등에서 그리는 값을 `0`에서 `160`으로 변경하고, `redrawMask`에서 `m !== 255`일 때 보이도록 시각화 조건을 넓혔습니다.
2. **YAML 포맷:** `jsyaml.dump` 후 `replace` 정규식을 사용하여 `origin` 리스트가 세로로 나열되는 것을 가로 `[x, y, z]` 포맷으로 강제했습니다.

이 수정을 적용하면 Nav2 Costmap Filter에서 160 값을 가진 Keep-out 존을 정상적으로 인식하고, YAML 파일도 깔끔하게 저장될 것입니다.

#########################  
###########################  
#############################  
네, 가능합니다. Nav2의 Costmap Filter(Keepout Filter)를 사용할 때 `mode: scale`을 사용하면 픽셀 값에 따라 Cost를 다르게 적용할 수 있어 매우 유용하죠.

**Download Keepout Mask** 버튼의 클릭 이벤트 핸들러(`$('#btnDownloadMask').on('click', ...)`) 부분만 아래 코드로 통째로 교체하시면 됩니다.

이 코드는 다음 세 가지를 수행합니다:

1. **속성 강제 변경:** `mode`, `occupied_thresh`, `free_thresh` 값을 원하시는 대로 고정합니다.
2. **Origin 포맷 유지:** 앞서 요청하신 `origin: [x, y, z]` 포맷 변환 로직을 포함하고 있습니다.
3. **이미지 경로 업데이트:** 저장되는 마스크 이미지 파일명으로 업데이트합니다.

### 수정할 코드 부분

기존의 `$('#btnDownloadMask').on('click', ...)` 부분을 찾아서 아래 코드로 덮어쓰세요.

```javascript
  $('#btnDownloadMask').on('click', ()=>{
    if(!pgm || !yamlObj || !mask){ alert('Load YAML and PGM first.'); return; }
    
    // 1. 마스크 PGM 데이터 생성
    const m = { magic:'P5', width: pgm.width, height: pgm.height, maxval: 255, pixels: mask };
    const maskBytes = encodePGM(m);
    
    // 2. 파일명 생성
    const base = (pgmName||'map.pgm').replace(/\.pgm$/i,'');
    const outMaskPgm = base + '_keepout.pgm';
    const outMaskYaml = base + '_keepout.yaml';
    
    // 3. YAML 객체 생성 (기존 정보 + 이미지 경로 + 요청하신 파라미터 강제 덮어쓰기)
    const y = Object.assign({}, yamlObj, { 
      image: outMaskPgm,
      mode: 'scale',
      occupied_thresh: 1.0,
      free_thresh: 0.0
    });
    
    // 4. YAML 문자열 변환 및 Origin 포맷 수정 ([x,y,z] 한 줄로)
    let yamlStr = jsyaml.dump(y, { lineWidth: 1000 });
    yamlStr = yamlStr.replace(/origin:\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)/g, 'origin: [$1, $2, $3]');
    
    // 5. 파일 다운로드 실행
    dlBytes(maskBytes, outMaskPgm, 'image/x-portable-graymap');
    dlText(yamlStr, outMaskYaml, 'text/yaml');
  });

```

### 적용 원리

`Object.assign({}, yamlObj, { ... })` 함수는 뒤에 오는 객체의 속성들이 앞의 객체 속성을 덮어쓰는(overwrite) 성질을 가집니다. 따라서 기존 `yamlObj`에 어떤 값이 있었든 상관없이, 우리가 지정한 `mode`, `thresh` 값들이 최종적으로 저장됩니다.

#####################  
############################  
###################################  
네, 맞습니다. 자바스크립트에서는 `1.0`과 `1`을 동일한 숫자(Number)로 취급하기 때문에, `js-yaml` 라이브러리가 덤프할 때 소수점 아래가 0이면 자동으로 정수(`1`, `0`)로 변환하여 출력해 버립니다.

이를 강제로 `1.0`, `0.0`으로 맞추기 위해서는, 아까 `origin` 배열을 수정했던 것처럼 **문자열로 변환된 후에 강제로 내용을 바꿔치기(Replace)** 하는 방법이 가장 확실합니다.

`$('#btnDownloadMask').on('click', ...)` 부분을 아래 코드로 다시 업데이트해 주세요.

### 수정된 코드

```javascript
  $('#btnDownloadMask').on('click', ()=>{
    if(!pgm || !yamlObj || !mask){ alert('Load YAML and PGM first.'); return; }
    
    // 1. 마스크 PGM 데이터 생성
    const m = { magic:'P5', width: pgm.width, height: pgm.height, maxval: 255, pixels: mask };
    const maskBytes = encodePGM(m);
    
    // 2. 파일명 생성
    const base = (pgmName||'map.pgm').replace(/\.pgm$/i,'');
    const outMaskPgm = base + '_keepout.pgm';
    const outMaskYaml = base + '_keepout.yaml';
    
    // 3. YAML 객체 생성
    // 여기서 1.0을 넣어도 JS는 1로 인식하므로, 아래 단계 4에서 문자열 치환으로 해결합니다.
    const y = Object.assign({}, yamlObj, { 
      image: outMaskPgm,
      mode: 'scale',
      occupied_thresh: 1.0, 
      free_thresh: 0.0
    });
    
    // 4. YAML 문자열 변환 및 포맷 강제 수정
    let yamlStr = jsyaml.dump(y, { lineWidth: 1000 });

    // [Fix 1] origin 포맷을 [x, y, z] 한 줄로 변경
    yamlStr = yamlStr.replace(/origin:\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)/g, 'origin: [$1, $2, $3]');
    
    // [Fix 2] occupied_thresh: 1 -> 1.0 변경
    // (정규식 설명: occupied_thresh: 뒤에 공백과 숫자 1이 오고, 줄바꿈이나 끝이 오는 경우를 찾음)
    yamlStr = yamlStr.replace(/occupied_thresh:\s*1(\s*)$/m, 'occupied_thresh: 1.0$1');
    
    // [Fix 3] free_thresh: 0 -> 0.0 변경
    yamlStr = yamlStr.replace(/free_thresh:\s*0(\s*)$/m, 'free_thresh: 0.0$1');
    
    // 5. 다운로드 실행
    dlBytes(maskBytes, outMaskPgm, 'image/x-portable-graymap');
    dlText(yamlStr, outMaskYaml, 'text/yaml');
  });

```

### 변경 사항 설명

코드 중간에 `[Fix 2]`와 `[Fix 3]` 주석 부분을 추가했습니다.

* `yamlStr.replace(...)` 함수를 사용하여, 생성된 텍스트 파일 내용 중 `occupied_thresh: 1`이라고 적힌 부분을 찾아서 강제로 `occupied_thresh: 1.0`으로 바꿔치기합니다. `free_thresh`도 마찬가지로 적용됩니다.
* 이렇게 하면 자바스크립트의 숫자 타입 특성과 상관없이 원하시는 결과물을 얻을 수 있습니다.

###################################  
#######################################  
##########################################  
260127  
웹 브라우저의 보안 정책상 **"파일이 저장될 폴더 경로(Path)"를 자바스크립트로 강제로 지정하는 것은 불가능**합니다. (항상 브라우저의 기본 다운로드 폴더로 저장되거나, 사용자가 직접 폴더를 선택하는 창이 뜹니다.)

하지만 **"파일명"**은 우리가 원하는 대로, **[현재날짜_시분초]** 포맷을 붙여서 지정할 수 있습니다.

아래 순서대로 코드를 수정해 보세요.

---

### 1단계: 날짜 생성 함수 추가

스크립트 내부, `(function(){ ...` 바로 안쪽이나 상단 변수 선언부 근처에 아래 함수를 추가합니다. 현재 시간을 `20250709_143000` 같은 문자열로 만들어주는 함수입니다.

```javascript
  // 날짜 포맷 헬퍼 (YYYYMMDD_HHMMSS)
  function getTimestamp() {
    const now = new Date();
    const pad = n => String(n).padStart(2, '0');
    const yyyy = now.getFullYear();
    const mm = pad(now.getMonth() + 1);
    const dd = pad(now.getDate());
    const hh = pad(now.getHours());
    const min = pad(now.getMinutes());
    const ss = pad(now.getSeconds());
    return `${yyyy}${mm}${dd}_${hh}${min}${ss}`;
  }

```

---

### 2단계: 'Download Map' 버튼 로직 수정

기존 `$('#btnDownloadMap').on('click', ...)` 부분을 아래 코드로 교체합니다.

```javascript
  $('#btnDownloadMap').on('click', ()=>{
    if(!pgm || !yamlObj){ alert('Load YAML and PGM first.'); return; }
    
    // 1. 타임스탬프 생성
    const ts = getTimestamp();
    const base = (pgmName || 'map').replace(/\.pgm$/i, ''); // 확장자 제거된 이름
    
    // 2. 파일명 지정 (_edited_[날짜].pgm)
    const outPgm = `${base}_edited_${ts}.pgm`;
    const outYaml = `${base}_edited_${ts}.yaml`;
    
    // 3. YAML 내부 image 경로 업데이트 및 포맷 수정
    const pgmBytes = encodePGM(pgm);
    
    // image 경로를 새 파일명으로 변경
    const y = Object.assign({}, yamlObj, { image: outPgm });
    
    // YAML 덤프 후 origin 포맷 교정 ([x,y,z] 한 줄로)
    let yamlStr = jsyaml.dump(y, { lineWidth: 1000 });
    yamlStr = yamlStr.replace(/origin:\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)/g, 'origin: [$1, $2, $3]');

    dlBytes(pgmBytes, outPgm, 'image/x-portable-graymap');
    dlText(yamlStr, outYaml, 'text/yaml');
  });

```

---

### 3단계: 'Download Keepout Mask' 버튼 로직 수정

이전에 요청하신 **`occupied_thresh: 1.0`**, **`origin` 포맷 수정**, **`128` (또는 `94`) 값 설정** 등을 모두 유지하면서 파일명만 변경하는 코드입니다.

기존 `$('#btnDownloadMask').on('click', ...)` 부분을 아래 코드로 **완전히 교체**하세요.

```javascript
  $('#btnDownloadMask').on('click', ()=>{
    if(!pgm || !yamlObj || !mask){ alert('Load YAML and PGM first.'); return; }
    
    // 1. 타임스탬프 생성
    const ts = getTimestamp();
    const base = (pgmName || 'map').replace(/\.pgm$/i, '');
    
    // 2. 파일명 지정 (_keepout_[날짜].pgm)
    const outMaskPgm = `${base}_keepout_${ts}.pgm`;
    const outMaskYaml = `${base}_keepout_${ts}.yaml`;

    // 3. 마스크 PGM 데이터 생성
    const m = { magic:'P5', width: pgm.width, height: pgm.height, maxval: 255, pixels: mask };
    const maskBytes = encodePGM(m);
    
    // 4. YAML 객체 생성 (이미지 경로 + 파라미터 강제)
    const y = Object.assign({}, yamlObj, { 
      image: outMaskPgm,
      mode: 'scale',
      occupied_thresh: 1.0, 
      free_thresh: 0.0
    });
    
    // 5. YAML 문자열 변환 및 포맷 교정
    let yamlStr = jsyaml.dump(y, { lineWidth: 1000 });

    // [Fix 1] origin 포맷 교정
    yamlStr = yamlStr.replace(/origin:\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)\s*\n\s*-\s*([0-9.-]+)/g, 'origin: [$1, $2, $3]');
    
    // [Fix 2] occupied_thresh: 1 -> 1.0 강제 변환
    yamlStr = yamlStr.replace(/occupied_thresh:\s*1(\s*)$/m, 'occupied_thresh: 1.0$1');
    
    // [Fix 3] free_thresh: 0 -> 0.0 강제 변환
    yamlStr = yamlStr.replace(/free_thresh:\s*0(\s*)$/m, 'free_thresh: 0.0$1');
    
    // 6. 다운로드 실행
    dlBytes(maskBytes, outMaskPgm, 'image/x-portable-graymap');
    dlText(yamlStr, outMaskYaml, 'text/yaml');
  });

```

### 결과

이제 다운로드 버튼을 누르면:

1. **파일명:** `map_keepout_20250709_143000.yaml` 처럼 현재 시간이 자동으로 붙습니다.
2. **YAML 내용:** `image: map_keepout_20250709_143000.pgm`으로 내부 경로도 자동으로 맞춰집니다.
3. **저장 위치:** 브라우저 설정에 따라 '다운로드' 폴더에 저장되거나, 저장 위치를 묻는 창이 뜹니다.