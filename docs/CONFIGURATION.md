# 설정과 감독 정책

[프로젝트 홈](../README.md)

신뢰도, 쿨다운과 조치 적용 조건을 설명합니다. 실행 예제는 [사용 안내](USER_GUIDE.md)를 참고하세요.

## 동작 흐름과 정책

```text
플랜트 한 구간 적분 → 수치 스냅샷 → summarizeSim
  → jevClient(mock/live) → superviseStep → applyAction
  → 이력 기록·UI 갱신 → 다음 구간
```

고정된 질문은 `action`(choice), `health`(score), `physically_plausible`(noul) 세 가지입니다. 함수 시그니처와 JSON 구조는 [인터페이스 계약](CONTRACT.md)을 참고합니다.

| 조치 | 적용 시 동작 |
|---|---|
| `continue` | 현재 솔버와 허용오차 유지 |
| `tighten` | RelTol과 AbsTol을 각각 0.1배로 축소, 하한은 1e-9 |
| `switch_solver` | ode45 ↔ ode15s 전환 |
| `abort` | 실행 중단 |

정책은 다음 순서로 평가합니다.

1. 제안이 abort이고, `actionConf >= 0.70`, `plausible < 0.15`, `healthScore >= 2.5` 중 하나라도 만족하면 중단합니다. 타당성·건강도 조건만으로 abort 제안을 새로 만들지는 않습니다.
2. 일반 자동 적용 신뢰도 기준보다 낮으면 제안만 기록하고 continue를 유지합니다.
3. 같은 종류의 tighten 또는 switch_solver가 최근 쿨다운 안에 이미 적용되었으면 재적용하지 않습니다. 거절된 제안은 쿨다운을 시작하지 않습니다.
4. 통과한 조치를 적용합니다. 앱에서 Auto apply가 꺼져 있으면 abort 외의 적용은 차단합니다.

### 주요 설정

`defaultConfig()`로 새 설정을 만든 뒤 필요한 값만 변경합니다.

| 설정 | 기본값 | 설명 |
|---|---|---|
| `cfg.sim.tEnd` | 8 | 시뮬레이션 종료 시각 |
| `cfg.sim.dt` | 0.01 | 청크 길이를 계산하는 기준 시간. ODE 솔버 내부 고정 스텝이 아님 |
| `cfg.sim.mu` / `x0` | 1000 / `[2;0]` | Van der Pol 계수와 초기 상태 |
| `cfg.sim.solver` | `"ode45"` | 초기 솔버, ode45 또는 ode15s |
| `cfg.sim.relTol` / `absTol` | 1e-3 / 1e-6 | 초기 적분 허용오차 |
| `cfg.supervisor.intervalSteps` | 20 | 청크 길이 = intervalSteps × dt |
| `cfg.supervisor.minIntervalSec` | 0.4 | 감독 호출 사이의 최소 실제 시간 간격 |
| `cfg.supervisor.autoApplyMinConf` | 0.80 | 일반 조치 자동 적용 신뢰도 기준 |
| `cfg.supervisor.abortMinConf` | 0.70 | abort 신뢰도 조건 |
| `cfg.supervisor.noulAbort` | 0.85 | abort 타당성 조건은 plausible < 1 − 이 값 |
| `cfg.supervisor.healthAbortScore` | 2.5 | abort 건강도 조건 |
| `cfg.supervisor.cooldownSteps` | 40 | 동일 조치 재적용까지의 기준 스텝 간격 |
| `cfg.supervisor.hysteresis` | 0.08 | 현재 정책에서 사용하지 않는 예약 설정 |
| `cfg.api.timeoutSec` | 8 | live HTTP 요청 타임아웃 |

`nSteps`는 ODE 솔버 내부의 적응형 스텝 수가 아니라 청크마다 intervalSteps씩 증가하는 카운터입니다. 빠른 오프라인 실험에서는 `cfg.supervisor.minIntervalSec = 0`으로 대기를 없앨 수 있습니다.

---

관련 문서: [인터페이스 계약](CONTRACT.md) · [사용 안내](USER_GUIDE.md)
