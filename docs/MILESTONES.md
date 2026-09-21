# 구현 마일스톤

MATLAB에서 먼저 `addpath(genpath(pwd))`를 실행합니다.

| 단계 | 생성/변경 파일 | 검증 명령 |
|---|---|---|
| 1 하네스 원문 | `src/defaultConfig.m`, `src/jevQuestions.m`, `harness/mockJev.m`, `harness/fixtures.m` | `f=fixtures(); mockJev(f.stiffOnOde45)` |
| 2 요약기 | `src/summarizeSim.m`, `harness/test_summarizeSim.m` | `assertSuccess(runtests('harness/test_summarizeSim.m'))` |
| 3 정책 | `src/superviseStep.m`, `src/applyAction.m`, `harness/test_superviseStep.m` | `assertSuccess(runtests('harness/test_superviseStep.m'))` |
| 4 클라이언트 | `src/jevClient.m`, `src/normalizeJevResponse.m`, `harness/test_jevClient_mock.m` | `assertSuccess(runtests('harness/test_jevClient_mock.m'))` |
| 5 헤드리스 | `src/makeDemoPlant.m`, `src/runDemoLoop.m`, `src/appendLog.m`, `harness/test_runDemoLoop.m` | `hist=runDemoLoop(defaultConfig); assert(abs(hist(end).t-8)<1e-10)` |
| 6 앱 | `app/SupervisorApp.mlapp`, `app/SupervisorAppSource.m`, `app/SupervisorApp_logic.m`, `app/buildSupervisorApp.m`, `harness/test_SupervisorApp.m` | `assertSuccess(runtests('harness/test_SupervisorApp.m')); SupervisorApp` |
| 7 문서 | `README.md`, `docs/CONTRACT.md`, `docs/MILESTONES.md`, `.gitignore`, `logs/.gitkeep` | README 실행 예제 및 `assertSuccess(runtests('harness'))` |

초기 하네스 네 파일은 구현 당시 제공된 코드와 동일하게 생성했습니다.
폴더는 실행 가능한 일반 MATLAB 경로 `src`, `app`, `harness`를 사용합니다.
`+src` 패키지 경로를 쓰면 고정된 비한정 함수 호출과 충돌합니다.
현재 사용 안내는 [README](../README.md), 인터페이스 기준은
[CONTRACT.md](CONTRACT.md)를 참고합니다.

## 검증 결과 (MATLAB R2025a, 2026-09-21)

- 전체 함수 기반 테스트 9개 통과: 요약 1, 정책 2, 클라이언트 2,
  헤드리스 1, 실제 앱 콜백 3.
- `runDemoLoop(defaultConfig)` 정상 종료: t=8, 감독 기록 40행,
  ode45 유지, switch_solver 제안, low_confidence 정책.
- 자동 적용 기준 0.60에서는 ode15s 변경 확인.
- InjectBlowup 버튼 콜백의 실제 10배 상태 주입 후 abort 확인.
  Auto 적용을 꺼도 abort하며, Stop 버튼 및 키 없는 live 정지도 확인.
- 원문 하네스 네 파일의 내용 비교 통과.
- App Designer 실제 파일 로더 `Status=success`, 컴포넌트 로드 오류 없음,
  콜백 4개 연결 복원 확인. 실행 후 화면 렌더링 검토 완료.
- live 서비스 호출은 수행하지 않음. JSON 매핑과 키 누락은 오프라인 검증.

## 사용 문서 보강 (2026-09-21)

- README를 한국어 사용 안내로 확장: 적용 시나리오, 준비 사항, 헤드리스·앱
  실행, 설정, 정책, 로그 분석, live 연결, 모델 확장, 문제 해결.
- 기존 개발 백서 문서 삭제. 유지할 인터페이스 계약과 이 문서의 참조 정리.
- 이번 변경은 문서에 한정하며, 코드와 예제의 대조 및 로컬 링크를 점검함.
  위의 MATLAB 테스트 결과는 구현 시 수행한 결과이며 이번에 재실행하지 않음.

## 문서 분할 (2026-09-21)

- README를 소개·빠른 시작·문서 안내 중심으로 축소.
- 상세 내용을 [사용 안내](USER_GUIDE.md), [설정과 정책](CONFIGURATION.md),
  [로그 분석](LOGGING.md), [Live API](LIVE_API.md),
  [모델 연동](INTEGRATION.md), [개발 안내](DEVELOPMENT.md)로 이동.
- 기존 README의 상세 섹션 11개가 모두 이동되었는지 확인하고,
  문서·소스 상대 링크와 코드 블록 구분자를 검증함. 문서 변경으로 MATLAB 테스트는 재실행하지 않음.
