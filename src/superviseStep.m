function policy = superviseStep(decision, snap, cfg, hist)
policy = struct('apply',false,'action',"continue",'reason',"continue", ...
    'simUpdate',struct('solver',string(snap.solver),'relTol',snap.relTol, ...
    'absTol',snap.absTol,'stop',false));
s = cfg.supervisor;
action = string(decision.action);
if action == "abort" && (decision.actionConf >= s.abortMinConf || ...
        decision.plausible < 1-s.noulAbort || decision.healthScore >= s.healthAbortScore)
    policy.apply = true; policy.action = "abort";
    policy.reason = "abort_gate"; policy.simUpdate.stop = true;
    return
end
if decision.actionConf < s.autoApplyMinConf
    policy.reason = "low_confidence";
    return
end
% Only applied actions start a cooldown. Rejected proposals do not extend it.
if any(action == ["tighten","switch_solver"])
    for k = numel(hist):-1:1
        if hist(k).applied && string(hist(k).action) == action
            if snap.nSteps - hist(k).nSteps < s.cooldownSteps
                policy.reason = "cooldown";
                return
            end
            break
        end
    end
end
switch action
    case "tighten"
        policy.simUpdate.relTol = max(1e-9, snap.relTol * 0.1);
        policy.simUpdate.absTol = max(1e-9, snap.absTol * 0.1);
    case "switch_solver"
        if string(snap.solver) == "ode45"
            policy.simUpdate.solver = "ode15s";
        else
            policy.simUpdate.solver = "ode45";
        end
    otherwise
        action = "continue";
end
policy.action = action; policy.apply = true; policy.reason = action;
% hysteresis is reserved: the six contract rules specify no extra gate.
end
