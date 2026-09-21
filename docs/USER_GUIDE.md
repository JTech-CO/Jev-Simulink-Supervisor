# 실행 및 앱 사용 안내

[프로젝트 홈](../README.md)

처음 실행하는 경우 준비 사항부터 순서대로 따라가세요. 모든 MATLAB 예제는 저장소 루트에서 실행합니다.

## 준비 사항

- MATLAB 설치가 필요합니다. 구현 및 검증 환경은 **MATLAB R2025a**입니다.
- 앱을 사용하려면 MATLAB의 그래픽 UI 실행 환경이 필요합니다. 헤드리스 실행에는 앱 창을 열지 않습니다.
- 현재 ODE 데모에는 Simulink와 API 키가 필요하지 않습니다.
- 소스 전체를 내려받은 뒤 MATLAB의 **Current Folder**를 이 저장소 루트로 설정합니다. `src`, `harness`, `app` 폴더가 모두 있어야 합니다. 기본 mock 실행에도 `harness/mockJev.m`이 필요합니다.

아래 예제는 모두 저장소 루트에서 실행합니다.

## 1. API 키 없이 첫 실행

MATLAB Command Window에서 실행합니다.

```matlab
addpath(genpath(pwd));
cfg = defaultConfig();
hist = runDemoLoop(cfg, []);

T = struct2table(hist);
disp(T(:, {'t','solver','action','conf','policyAction','reason'}));
```

`hist = runDemoLoop(defaultConfig);`도 같은 방식으로 동작합니다. 두 번째 인수를 생략하면 앱 없이 실행합니다.

기본 플랜트는 `mu=1000`, 초기 상태 `[2;0]`, 시작 솔버 `ode45`, 종료 시각 `t=8`입니다. 기본 실행은 시뮬레이션 시간 0.2초마다 판단하여 **40행**을 기록합니다. 감독 호출에는 실제 시간 간격도 적용하므로 시뮬레이션 시간 8초와 실제 실행 시간은 같지 않습니다.

첫 실행의 예상 결과는 다음과 같습니다.

| 항목 | 예상 값 | 의미 |
|---|---|---|
| `action` | `switch_solver` | mock의 솔버 변경 제안 |
| `conf` | `0.65` | 제안 신뢰도 |
| `policyAction` | `continue` | 실제로 유지할 동작 |
| `reason` | `low_confidence` | 자동 적용 기준 0.80 미달 |
| `applied` | `false` | 제안이 적용되지 않음 |
| `solver` | `ode45` | 현재 솔버 유지 |

**기본 실행에서 솔버가 바뀌지 않는 것은 정상 동작입니다.** 또한 ode45가 실제 경고를 발생시키지 않아도 Jacobian 기반 강성 지표로 mock이 변경을 제안할 수 있습니다.

## 2. 솔버 변경이 적용되는 실행

데모에서 적용 경로를 확인하려면 신뢰도 기준을 0.60으로 낮춥니다.

```matlab
cfg = defaultConfig();
cfg.supervisor.autoApplyMinConf = 0.60;
hist = runDemoLoop(cfg, []);

T = struct2table(hist);
disp(T(:, {'t','solver','action','applied','policyAction'}));
```

첫 판단에서 `switch_solver`가 적용되고, 다음 적분 구간부터 `ode15s`를 사용합니다. 로그의 `solver`는 **판단 전 스냅샷의 솔버**이므로 변경이 적용된 행 자체에는 여전히 ode45가 표시될 수 있습니다. 임계값 0.60은 적용 과정을 보여주기 위한 데모 설정이며 다른 모델의 권장값을 뜻하지 않습니다.

## 3. 대시보드 사용

```matlab
addpath(genpath(pwd));
app = SupervisorApp;
```

1. 모드를 `mock`으로 두고 **Start**를 누릅니다.
2. 상태 곡선, 수치 건강도, 제안 action, 신뢰도, 정책 사유를 확인합니다.
3. 실행 중 **InjectBlowup**을 눌러 다음 감독 경계에서 상태를 한 번 10배로 만듭니다. 에너지 지표가 급증하면 mock이 abort를 제안하고 실행이 중단됩니다.
4. **Stop**은 사용자 요청으로 실행을 중단합니다. **Start**를 다시 누르면 초기 상태와 새 이력으로 시작합니다.

| 화면 요소 | 읽는 방법 / 동작 |
|---|---|
| `ModeDropDown` | mock 또는 live 선택. 실행 중에는 변경 불가 |
| `AutoCheckBox` | 일반 조치의 자동 적용 허용. 켜도 신뢰도·쿨다운 검사를 통과해야 함 |
| `StateAxes` | x1, x2의 시간 변화 |
| `HealthAxes` | 수치 건강도 점수. 0에 가까우면 양호, 3에 가까우면 불량 |
| `ActionLabel` | Jev/mock의 제안. 실제 적용 여부는 표와 사유를 함께 확인 |
| `ConfGauge` | 제안 action의 신뢰도, 0–1 |
| `PlausibleGauge` | 궤적의 타당성 판단값, 0–1 |
| `ReasonText` | `low_confidence`, `cooldown`, `auto_disabled`, `abort_gate` 등 정책 사유 |
| `LogTable` | 감독 주기별 t, action, conf, health, plausible, applied |
| `StatusLabel` | 모드, 적용된 솔버·허용오차, 종료·오류 상태 |

Auto apply를 꺼도 **정책 조건을 충족한 abort는 적용**됩니다. 실행 중이 아닐 때 InjectBlowup은 상태를 변경하지 않습니다. Stop과 창 닫기는 적분/대기 중 UI 이벤트 처리 시 반영됩니다. live HTTP 요청은 동기 호출이므로 요청 중에는 응답 또는 타임아웃까지 UI 반응이 지연될 수 있습니다.

앱 설정은 Start를 누르기 전에 MATLAB에서 변경할 수 있습니다.

```matlab
app = SupervisorApp;
cfg = defaultConfig();
cfg.sim.tEnd = 4;
cfg.supervisor.autoApplyMinConf = 0.60;
app.Config = cfg;
app.ModeDropDown.Value = 'mock';
% 이제 앱에서 Start를 누릅니다.
```

앱에서는 드롭다운 값이 `app.Config.api.mode`보다 우선합니다. 실행 후 `app.History`로 결과를 읽을 수 있습니다. 실행 중 바뀐 솔버·허용오차는 해당 실행에만 적용되며 다음 Start의 초기 설정으로 자동 저장되지 않습니다.

## 자주 겪는 문제

| 증상 | 확인할 내용 |
|---|---|
| `defaultConfig` 또는 `SupervisorApp`를 찾지 못함 | 저장소 루트로 이동하고 `addpath(genpath(pwd))` 실행 |
| `mockJev`를 찾지 못함 | harness 폴더도 함께 내려받았는지 확인 |
| 제안은 switch_solver인데 솔버가 그대로임 | conf=0.65와 기본 기준 0.80 비교. 사유가 low_confidence이면 정상 |
| Auto apply를 켰는데 applied=false | 신뢰도 미달이나 cooldown일 수 있음. ReasonText 확인 |
| 에러 없이 실행이 예상보다 오래 걸림 | minIntervalSec는 실제 시간 대기이며 tEnd는 시뮬레이션 시간 |
| live에서 missing API key | MATLAB 프로세스가 keyEnv로 지정한 환경변수를 상속했는지 확인 |
| live에서 계속 continue / 신뢰도 0 | MAT의 diagnostics와 source를 확인. HTTP·응답 매핑 오류 가능 |
| Stop 반응이 늦음 | 동기 live 요청 중이면 응답·타임아웃까지 대기 가능 |
| 표의 솔버와 StatusLabel 솔버가 다름 | 표는 판단 전 스냅샷, 상태 표시는 조치 적용 후 설정 |

---

관련 문서: [설정과 정책](CONFIGURATION.md) · [로그 분석](LOGGING.md) · [Live API 연결](LIVE_API.md)
