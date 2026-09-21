function decision = mockJev(state)
% Deterministic offline stand-in. Keep thresholds aligned with superviseStep.
decision.source = "mock";
decision.latencyMs = 5;
decision.raw = struct();

res = getfielddef(state, "residualNorm", 0);
stiff = getfielddef(state, "stiffnessHint", 0);
maxAbs = getfielddef(state, "maxAbsState", 0);
nW = getfielddef(state, "nWarnings", 0);
trend = string(getfielddef(state, "energyTrend", "flat"));
solver = string(getfielddef(state, "solver", "ode45"));

blow = ~isfinite(maxAbs) || maxAbs > 1e6 || trend == "exploding";
stiffPoor = (stiff > 1e3 && solver == "ode45") || nW >= 2 || res > 50;

if blow
    decision.action = "abort";
    decision.actionP = struct("continue",0.01,"tighten",0.04,"switch_solver",0.10,"abort",0.85);
    decision.actionConf = 0.85;
    decision.healthScore = 3.0;
    decision.healthConf = 0.9;
    decision.plausible = 0.08;
elseif stiffPoor
    decision.action = "switch_solver";
    decision.actionP = struct("continue",0.08,"tighten",0.22,"switch_solver",0.65,"abort",0.05);
    decision.actionConf = 0.65;
    decision.healthScore = 2.1;
    decision.healthConf = 0.72;
    decision.plausible = 0.62;
elseif nW >= 1 || res > 5
    decision.action = "tighten";
    decision.actionP = struct("continue",0.25,"tighten",0.60,"switch_solver",0.12,"abort",0.03);
    decision.actionConf = 0.60;
    decision.healthScore = 1.3;
    decision.healthConf = 0.70;
    decision.plausible = 0.80;
else
    decision.action = "continue";
    decision.actionP = struct("continue",0.88,"tighten",0.08,"switch_solver",0.03,"abort",0.01);
    decision.actionConf = 0.88;
    decision.healthScore = 0.3;
    decision.healthConf = 0.90;
    decision.plausible = 0.96;
end

decision.healthP = struct("s0", nan, "s1", nan, "s2", nan, "s3", nan);
end

function v = getfielddef(s, name, default)
if isstruct(s) && isfield(s, name), v = s.(name); else, v = default; end
end
