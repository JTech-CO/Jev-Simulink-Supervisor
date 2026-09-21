# Jev-Simulink Supervisor 인터페이스 계약

설정, 스냅샷, 질문·결정 JSON, 정책, 함수 시그니처와 UI 이름의 기준 문서입니다.
실행 절차와 적용 방법은 [README](../README.md)를 참고합니다.
아래 절 번호는 기존 계약과의 대조를 위해 유지합니다.

## 3. 설정 계약 (`defaultConfig.m`이 반환)

```matlab
cfg.api.mode = "mock";          % "mock" | "live"
cfg.api.url = "https://api.typesafe.ai/v1/systemone";
cfg.api.model = "jev-latest";
cfg.api.keyEnv = "TYPESAFE_API_KEY";
cfg.api.timeoutSec = 8;

cfg.supervisor.intervalSteps = 20;
cfg.supervisor.minIntervalSec = 0.4;
cfg.supervisor.autoApplyMinConf = 0.80;
cfg.supervisor.abortMinConf = 0.70;
cfg.supervisor.noulAbort = 0.85;          % physically_plausible 이 이보다 낮고
cfg.supervisor.healthAbortScore = 2.5;    % health score가 이 이상이면 abort 후보
cfg.supervisor.cooldownSteps = 40;        % 연속 액션 남발 방지
cfg.supervisor.hysteresis = 0.08;

cfg.sim.tEnd = 8;
cfg.sim.dt = 0.01;
cfg.sim.solver = "ode45";                 % ode45 | ode15s
cfg.sim.relTol = 1e-3;
cfg.sim.absTol = 1e-6;
cfg.sim.mu = 1000;
cfg.sim.x0 = [2; 0];
```

---

## 4. 데이터 계약

### 4.1 시뮬 스냅샷 `snap` (MATLAB → 요약기)

```matlab
snap.t
snap.x                 % state vector
snap.xdot
snap.u                 % optional input
snap.residualNorm
snap.energy
snap.stiffnessHint     % max |eig| 또는 dt/timescale 비
snap.nSteps
snap.solver
snap.relTol
snap.absTol
snap.warnings          % string array
snap.lastAction
snap.notes             % 사용자/모델 메모
```

### 4.2 Jev state (JSON-able struct)

`summarizeSim` 출력. 숫자도 **짧은 텍스트로도** 넣는다. Jev는 텍스트 판단기다.

```json
{
  "t": 1.20,
  "solver": "ode45",
  "relTol": "1e-3",
  "absTol": "1e-6",
  "residualNorm": 3.4e2,
  "energy": 12.8,
  "energyTrend": "rising_fast",
  "maxAbsState": 41.2,
  "stiffnessHint": 1.8e4,
  "nWarnings": 2,
  "warnings": "Integration tolerance not met; step rejected",
  "lastAction": "continue",
  "notes": "Van der Pol mu=1000 stiff demo"
}
```

### 4.3 Jev questions (고정 스키마)

`jevQuestions.m`이 이 구조체를 반환. 바꾸지 말 것.  thr은 MATLAB이 적용.

```json
{
  "action": {
    "type": "choice",
    "instructions": "Choose the next supervisor action for this numerical integration. Prefer the least invasive action that keeps the trajectory physically plausible and numerically stable.",
    "criteria": {
      "continue": "Integration is healthy enough to keep current solver and tolerances.",
      "tighten": "Reduce step size or tighten RelTol/AbsTol. Do not change solver family.",
      "switch_solver": "Current solver is a poor fit (e.g. nonstiff solver on a stiff system). Switch solver family.",
      "abort": "Continuing is unsafe or meaningless. Stop now."
    }
  },
  "health": {
    "type": "score",
    "instructions": "Score numerical health of this run. 0 is stable and well-scaled. 3 is diverging or unusable.",
    "criteria": [
      "stable: residuals small, energy bounded, no repeated step failures",
      "noisy: usable but tolerances or steps are strained",
      "stiff_or_poorly_scaled: likely wrong solver or scales",
      "diverging_or_unusable: blow-up, NaN risk, or physically implausible"
    ]
  },
  "physically_plausible": {
    "type": "noul",
    "instructions": "Is the current trajectory still physically or numerically plausible given notes, energy trend, and warnings?"
  }
}
```

### 4.4 정규화된 결정 `decision`

```matlab
decision.action          % string
decision.actionP         % struct of probabilities
decision.actionConf
decision.healthScore     % 0..3
decision.healthConf
decision.healthP
decision.plausible       % 0..1 noul
decision.raw             % original response
decision.source          % "mock" | "live"
decision.latencyMs
```

### 4.5 정책 출력 `policy`

```matlab
policy.apply             % logical  자동 적용 여부
policy.action            % 실제 적용할 액션 (continue일 수 있음)
policy.reason            % short string
policy.simUpdate         % struct: solver, relTol, absTol, stop
```

정책 규칙 (그대로 구현):

1. `action=="abort"` 이고 (`actionConf >= abortMinConf` 또는 `plausible < 1-noulAbort` 또는 `healthScore >= healthAbortScore`) → stop.
2. `actionConf < autoApplyMinConf` → UI만 표시, 시뮬은 `continue` 유지. reason=`low_confidence`.
3. 같은 계열 액션이 cooldown 안이면 `continue`.
4. `tighten`: relTol, absTol을 0.1배로. 하한 1e-9.
5. `switch_solver`: ode45↔ode15s 토글. 방금 바꾼 뒤 cooldown.
6. 그 외 continue.

---

## 5. 함수 시그니처 (변경 금지)

```matlab
function cfg = defaultConfig()
function questions = jevQuestions()
function state = summarizeSim(snap)
function [decision, diag] = jevClient(state, questions, cfg)
function policy = superviseStep(decision, snap, cfg, hist)
function [sim, cfg] = applyAction(sim, cfg, policy)
function logRow = appendLog(logRow, snap, state, decision, policy)
function sim = makeDemoPlant(cfg)           % MATLAB 등가 플랜트
function hist = runDemoLoop(cfg, appHandle) % appHandle는 [] 가능
```

`jevClient` live 경로:
- POST JSON `{model, state, questions}`
- Header `Authorization: Bearer <TYPESAFE_API_KEY>`
- `Content-Type: application/json`
- 응답 `answers.action|health|physically_plausible`를 `decision`으로 매핑
- 실패 시 mock이 아니라 **안전한 fallback**: action=continue, actionConf=0, source="error", reason in diag

Score 매핑: criteria 4단계면 score 0..3. 소수 허용.

---

## 6. 데모 플랜트 (1차, Simulink 없이)

Van der Pol 강성 시스템.

\[
\dot x_1 = x_2,\quad \dot x_2 = \mu(1-x_1^2)x_2 - x_1,\quad \mu=1000
\]

- 초기값 `[2; 0]`
- `ode45`로 시작하면 경고/스텝 거부가 나고 Jev가 `switch_solver` 또는 `tighten`을 고를 여지
- `ode15s`면 대체로 continue
- `residualNorm ≈ ||f(x)||` 또는 최근 스텝 실패 횟수
- `energy = 0.5*(x1^2 + x2^2)` (물리 에너지 아님. 스케일 힌트)
- 고의 발산 버튼: `x = x * 10` 한 번 곱해 abort 경로 테스트

2차에만 `plant_stiff.slx` + `StopFcn`/` periodically` MATLAB Function으로 `superviseStep` 호출.

---

## 7. App Designer UI 계약

앱 이름: `SupervisorApp`

컴포넌트 태그(이름 고정):

| 이름 | 타입 | 역할 |
|---|---|---|
| StartButton | Button | 루프 시작 |
| StopButton | Button | 사용자 abort |
| ModeDropDown | DropDown | mock / live |
| AutoCheckBox | CheckBox | 자동 적용 on/off |
| StateAxes | UIAxes | x1, x2 vs t |
| HealthAxes | UIAxes | healthScore vs t |
| ActionGauge 또는 ActionLabel | Label | 현재 action |
| ConfGauge | Gauge 0–1 | actionConf |
| PlausibleGauge | Gauge 0–1 | noul |
| ReasonText | TextArea | policy.reason |
| LogTable | Table | t, action, conf, health, plausible, applied |
| InjectBlowupButton | Button | 발산 주입 |
| StatusLabel | Label | mock/live, solver, tol |

동작:
- `runDemoLoop`는 `drawnow limitrate`로 UI 갱신
- 루프는 앱의 `Running` 플래그로 중단
- live 모드인데 키 없으면 StatusLabel에 에러, mock으로 강제 전환하지 말고 정지

---

