# Live API 연결

[프로젝트 홈](../README.md)

API 키 없이 시작하려면 먼저 [mock 실행 안내](USER_GUIDE.md)를 따라가세요. 아래 예제는 저장소 루트에서 addpath(genpath(pwd))를 실행한 상태를 가정합니다.

## Live API 연결

먼저 mock으로 정책과 UI 동작을 확인한 뒤 live로 전환합니다. API 클라이언트는 구현되어 있지만 **실제 서비스와의 통신은 검증하지 않았습니다.** 아래 URL과 모델명은 현재 코드의 기본 설정값입니다.

| 설정 | 기본값 |
|---|---|
| `cfg.api.url` | `https://api.typesafe.ai/v1/systemone` |
| `cfg.api.model` | `jev-latest` |
| `cfg.api.keyEnv` | `TYPESAFE_API_KEY` |

MATLAB을 실행하는 환경에 `TYPESAFE_API_KEY`를 설정하고, 이미 MATLAB이 열려 있었다면 새 환경변수가 전달되도록 다시 실행합니다. 키 값을 `.m` 파일이나 저장소에 적지 않습니다. MATLAB에서 값 자체를 출력하지 않고 전달 여부만 확인할 수 있습니다.

```matlab
assert(~isempty(strtrim(getenv('TYPESAFE_API_KEY'))), ...
    'MATLAB 프로세스에 API 키 환경변수가 없습니다.');
cfg = defaultConfig();
cfg.api.mode = "live";
hist = runDemoLoop(cfg, []);
```

앱에서는 키를 전달한 MATLAB에서 앱을 열고 모드를 live로 선택한 뒤 Start를 누릅니다.

명시적인 live 모드와 비어 있지 않은 키가 모두 있어야 HTTP 요청을 보냅니다. 전송 본문은 `{model, state, questions}`이며 수치 요약, 경고, notes가 포함됩니다. 전체 궤적이나 플롯 이미지는 보내지 않습니다. 키는 Authorization 헤더에만 사용하며 설정·로그에 키 값을 따로 저장하지 않습니다.

키가 없으면 헤드리스는 `Jev:MissingAPIKey` 오류로, 앱은 StatusLabel 오류 표시와 함께 정지합니다. 요청 실패나 잘못된 응답은 `source="error"`, `action="continue"`, `actionConf=0`으로 반환하며 mock으로 전환하지 않습니다. 이 fallback은 자동 변경을 막지만, API 장애 자체로 시뮬레이션을 중단하지는 않습니다. 원인은 MAT 파일의 `diagnostics`에서 확인합니다.

---

관련 문서: [사용 안내](USER_GUIDE.md) · [진단 로그 확인](LOGGING.md) · [인터페이스 계약](CONTRACT.md)
