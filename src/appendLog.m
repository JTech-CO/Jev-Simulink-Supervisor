function logRow = appendLog(logRow, snap, state, decision, policy)
logRow.t = snap.t;
logRow.nSteps = snap.nSteps;
logRow.x1 = snap.x(1); logRow.x2 = snap.x(2);
logRow.solver = string(snap.solver);
logRow.relTol = snap.relTol; logRow.absTol = snap.absTol;
logRow.energy = state.energy;
logRow.energyTrend = state.energyTrend;
logRow.action = decision.action;
logRow.conf = decision.actionConf;
logRow.health = decision.healthScore;
logRow.plausible = decision.plausible;
logRow.applied = policy.apply;
logRow.policyAction = policy.action;
logRow.reason = policy.reason;
logRow.stop = policy.simUpdate.stop;
logRow.source = decision.source;
logRow.latencyMs = decision.latencyMs;
logRow.warnings = state.warnings;
end
