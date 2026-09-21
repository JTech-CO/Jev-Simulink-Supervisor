# Jev-Simulink Supervisor

MATLAB 수치 시뮬레이션의 상태를 주기적으로 요약하고, 솔버·허용오차 유지 또는 조정, 실행 중단을 판단하는 **시뮬레이션 감독 도구**입니다. MATLAB이 적분·계산·시각화를 수행하고, Jev의 제안을 신뢰도와 쿨다운 정책에 따라 적용합니다.

현재는 **Van der Pol 강성 ODE 데모**를 제공합니다. API 키 없이 사용하는 mock, 헤드리스 실행, App Designer 대시보드, CSV/MAT 기록을 포함합니다. 솔버 비교 실험, 감독 정책 검증, 시뮬레이션 교육에 사용할 수 있습니다.

**현재 데모에는 Simulink가 필요하지 않습니다.** `simulink` 폴더는 비어 있으며 `.slx` 모델 자동 연동은 제공하지 않습니다. 실제 모델로 확장하는 방법은 [적용 시나리오와 모델 연동](docs/INTEGRATION.md)에 정리했습니다.

## 빠른 시작

검증 환경은 **MATLAB R2025a**입니다. 저장소 전체를 내려받고 MATLAB의 Current Folder를 저장소 루트로 설정합니다. 앱 실행에는 그래픽 UI 환경이 필요합니다.

앱 없이 실행:

```matlab
addpath(genpath(pwd));
hist = runDemoLoop(defaultConfig);
```

대시보드 실행:

```matlab
addpath(genpath(pwd));
app = SupervisorApp;
```

앱에서 `mock` 모드로 **Start**를 누릅니다. **Stop**으로 중단하거나 **InjectBlowup**으로 발산 주입 후 abort 경로를 확인할 수 있습니다.

기본 실행은 ode45로 시작해 시뮬레이션 시간 t=8까지 감독 기록 40행을 생성합니다. mock의 솔버 변경 신뢰도 0.65가 기본 자동 적용 기준 0.80보다 낮으므로, `low_confidence`와 함께 ode45를 유지하는 것이 정상입니다. 실제 솔버 변경 예제는 [실행 및 앱 사용 안내](docs/USER_GUIDE.md)를 참고하세요.

결과는 `logs`에 누적 저장됩니다. 자동 삭제되지 않으며, 필요 없는 CSV/MAT를 삭제해도 다음 실행에는 영향이 없습니다. 저장 형식과 분석 예제는 [로그 안내](docs/LOGGING.md)에 있습니다.

## 문서 안내

| 알고 싶은 내용 | 문서 |
|---|---|
| 설치 준비, 실행 예제, 앱 버튼·화면, 문제 해결 | [실행 및 앱 사용 안내](docs/USER_GUIDE.md) |
| 설정 기본값, 신뢰도·abort·쿨다운 규칙 | [설정과 감독 정책](docs/CONFIGURATION.md) |
| 결과 해석, CSV/MAT 읽기, 로그 보관·삭제 | [실행 결과와 로그 분석](docs/LOGGING.md) |
| 환경변수 키 설정, live 실행, API 오류 처리 | [Live API 연결](docs/LIVE_API.md) |
| 활용 범위, 다른 ODE·Simulink 모델 연결 | [적용 시나리오와 모델 연동](docs/INTEGRATION.md) |
| 소스 구성, 테스트, App Designer 편집·재빌드 | [개발 안내](docs/DEVELOPMENT.md) |
| 고정 함수 시그니처, JSON 스키마, UI 이름 | [인터페이스 계약](docs/CONTRACT.md) |
| 구현 단계 및 기존 테스트 결과 | [구현·검증 기록](docs/MILESTONES.md) |

Live 클라이언트는 구현되어 있지만 실제 서비스 통신은 검증하지 않았습니다. 먼저 mock으로 동작을 확인한 뒤 [Live API 안내](docs/LIVE_API.md)에 따라 연결하세요.
