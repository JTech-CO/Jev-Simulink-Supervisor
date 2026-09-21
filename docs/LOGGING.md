# 실행 결과와 로그 분석

[프로젝트 홈](../README.md)

헤드리스의 hist 또는 앱의 app.History로 현재 실행 결과를 읽고, 저장된 CSV/MAT로 이전 실행을 분석합니다. 예제의 hist는 실행을 마친 결과라고 가정하며, 명령은 저장소 루트에서 실행합니다.

## 결과 확인과 로그 분석

정상 완료, 정책 중단, 사용자 중단 시 `logs` 아래에 실행별 임의 이름의 MAT 파일을 저장합니다. 감독 기록이 하나 이상 있으면 같은 이름의 CSV도 저장합니다. 키 누락으로 시작 자체가 거절된 실행은 로그를 만들지 않습니다.

- CSV: 상태 두 개, 시간, 솔버·허용오차, 에너지, 제안·정책 조치, 신뢰도, 건강도, 타당성, 적용 여부, 정책 사유, 경고.
- MAT: `hist`, `decisions`, `policies`, `diagnostics`, 최종 `cfg`. 정규화된 결정의 `raw` 응답도 포함합니다.
- 로그는 기본적으로 Git 추적에서 제외됩니다. 전체 적분 궤적이 아니라 감독 시점의 이력을 저장합니다.

현재 실행의 적용된 조치를 찾는 예제입니다.

```matlab
T = struct2table(hist);
changed = T.applied & T.policyAction ~= "continue";
disp(T(changed, {'t','action','policyAction','reason'}));
```

`applied=true`인 continue 행도 존재할 수 있으므로, 이 값만으로 솔버가 바뀌었다고 해석하지 않습니다. `stop` 열은 정책의 중단 요청입니다. 사용자 Stop이나 적분 오류로 종료한 경우까지 모두 나타내는 종료 사유 필드는 아닙니다.

저장된 최신 기록과 API 진단을 읽는 예제입니다.

```matlab
files = dir(fullfile('logs', '*.mat'));
if ~isempty(files)
    [~, idx] = max([files.datenum]);
    run = load(fullfile(files(idx).folder, files(idx).name));
    disp(run.hist);
    if ~isempty(run.diagnostics)
        disp(run.diagnostics{end});
    end
end
```

## 보관과 삭제

로그는 실행마다 추가되며 자동 삭제되지 않습니다. 비교·분석에 필요한 파일은 보관하고, 필요 없는 실행의 CSV/MAT는 직접 삭제해도 다음 실행에 영향이 없습니다. 저장소의 `logs/.gitkeep`은 빈 폴더를 유지하기 위한 파일입니다.

---

관련 문서: [사용 안내](USER_GUIDE.md) · [Live API 연결](LIVE_API.md)
