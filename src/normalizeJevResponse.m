function decision = normalizeJevResponse(raw)
% Pure response mapping; deliberately independent of HTTP for offline tests.
a = raw.answers.action; h = raw.answers.health; p = raw.answers.physically_plausible;
assert(string(a.type)=="choice" && string(h.type)=="score" && string(p.type)=="noul", ...
    'Jev:InvalidResponse','Unexpected answer types.');
action = string(a.choice);
assert(isscalar(action) && any(action == ["continue","tighten","switch_solver","abort"]), ...
    'Jev:InvalidResponse','Unknown action.');
checkRange(a.confidence,1); checkRange(h.confidence,1);
checkRange(h.score,3); checkRange(p.noul,1);
ap = a.probabilities;
names = {'continue','tighten','switch_solver','abort'};
for k=1:4, checkRange(ap.(names{k}),1); end
assert(abs(sum(cellfun(@(n) ap.(n),names))-1)<1e-6,'Jev:InvalidResponse','Invalid probabilities.');
hp = struct();
for k=0:3
    name = matlab.lang.makeValidName(num2str(k));
    value = h.probabilities.(name); checkRange(value,1);
    hp.(sprintf('s%d',k)) = value;
end
assert(abs(sum(struct2array(hp))-1)<1e-6,'Jev:InvalidResponse','Invalid probabilities.');
decision = struct('action',action,'actionP',ap,'actionConf',a.confidence, ...
    'healthScore',h.score,'healthConf',h.confidence,'healthP',hp, ...
    'plausible',p.noul,'raw',raw,'source',"live",'latencyMs',0);
end
function checkRange(v, upper)
assert(isnumeric(v) && isscalar(v) && isfinite(v) && v>=0 && v<=upper, ...
    'Jev:InvalidResponse','Invalid numeric answer.');
end
