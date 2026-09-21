function tests = test_jevClient_mock
tests = functiontests(localfunctions);
end
function test_offline(t)
c=defaultConfig(); f=fixtures(); q=jevQuestions();
c.api.url = "http://127.0.0.1:1/never-call";
[d,g]=jevClient(f.stiffOnOde45,q,c);
verifyEqual(t,d,mockJev(f.stiffOnOde45)); verifyTrue(t,g.ok);
verifyEqual(t,sort(fieldnames(q)),sort({'action';'health';'physically_plausible'}));
c.api.mode="disabled";
[d,g]=jevClient(f.healthy,q,c); verifyEqual(t,d.source,"error"); verifyFalse(t,g.ok);
c.api.mode="live"; c.api.keyEnv='JEV_TEST_NONEXISTENT_KEY_70837';
[d,g]=jevClient(f.healthy,q,c);
verifyEqual(t,d.actionConf,0); verifyEqual(t,g.reason,"missing_api_key");
end
function test_mapping(t)
raw=jsondecode(['{"answers":{"action":{"type":"choice","choice":"switch_solver",' ...
    '"confidence":0.81,"probabilities":{"continue":0.07,"tighten":0.1,"switch_solver":0.81,"abort":0.02}},' ...
    '"health":{"type":"score","score":2.1,"confidence":0.74,"probabilities":{"0":0.05,"1":0.15,"2":0.7,"3":0.1}},' ...
    '"physically_plausible":{"type":"noul","noul":0.61}}}']);
d=normalizeJevResponse(raw);
verifyEqual(t,d.healthScore,2.1); verifyEqual(t,d.healthP.s2,0.7);
raw.answers.action.confidence=NaN;
verifyError(t,@() normalizeJevResponse(raw),'Jev:InvalidResponse');
end
