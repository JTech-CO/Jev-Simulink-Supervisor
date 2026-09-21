# 파일 구성과 개발 안내

[프로젝트 홈](../README.md)

테스트 실행, App Designer 편집 및 재빌드 방법입니다. 모든 명령은 저장소 루트에서 실행합니다.

## 파일 구성과 개발

| 위치 | 역할 |
|---|---|
| `src/defaultConfig.m`, `jevQuestions.m` | 설정 및 고정 질문 스키마 |
| `src/summarizeSim.m` | 수치 스냅샷의 JSON 가능 요약 변환 |
| `src/jevClient.m`, `normalizeJevResponse.m` | mock/live 요청 분기 및 응답 검증·정규화 |
| `src/superviseStep.m`, `applyAction.m` | 정책 평가 및 MATLAB 플랜트 설정 반영 |
| `src/makeDemoPlant.m`, `runDemoLoop.m`, `appendLog.m` | 데모 플랜트, 실행 루프, 기록 |
| `harness/` | 결정론적 mock, fixture 및 테스트 |
| `app/SupervisorApp.mlapp` | 실행·편집 가능한 App Designer 앱 |
| `app/SupervisorAppSource.m` | 검토·재빌드용 앱 소스 |
| `app/SupervisorApp_logic.m` | Start/Stop/주입 및 화면 갱신 로직 |
| `app/buildSupervisorApp.m` | 소스로부터 mlapp 재생성 |
| `logs/` | 실행별 CSV/MAT 출력 |
| [docs/CONTRACT.md](CONTRACT.md) | 함수·데이터·UI 인터페이스 계약 |
| [docs/MILESTONES.md](MILESTONES.md) | 구현 단계와 기존 검증 결과 |

전체 테스트:

```matlab
addpath(genpath(pwd));
results = runtests('harness');
assertSuccess(results);
```

테스트는 요약, 신뢰도·abort·쿨다운 정책, 오프라인 응답 매핑, 헤드리스 실행, 실제 앱 버튼 콜백을 검증합니다. 앱 테스트에는 그래픽 환경이 필요하며, 테스트 실행도 `logs`에 기록을 만듭니다. 기존 R2025a 검증에서 9개 테스트가 통과했습니다. live 서비스 통신은 포함하지 않습니다.

앱 편집 및 재빌드:

```matlab
appdesigner('app/SupervisorApp.mlapp');
% 소스에서 앱을 재생성할 때만 실행:
% buildSupervisorApp;
```

`buildSupervisorApp`는 R2025a 내부 App Designer 직렬화 API를 사용합니다. 다른 릴리스에서는 빌드 도구 수정이 필요할 수 있습니다. 재빌드는 기존 mlapp을 덮어쓰므로, App Designer에서 직접 수정한 디자인을 유지하려면 해당 mlapp을 보존하거나 변경을 빌드 소스에도 반영해야 합니다.

---

관련 문서: [인터페이스 계약](CONTRACT.md) · [구현·검증 기록](MILESTONES.md) · [모델 연동](INTEGRATION.md)
