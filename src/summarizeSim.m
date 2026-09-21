function state = summarizeSim(snap)
% Previous energy is explicit per-run history, never persistent shared state.
state.t = snap.t;
state.solver = string(snap.solver);
state.relTol = string(sprintf('%.3g', snap.relTol));
state.absTol = string(sprintf('%.3g', snap.absTol));
state.residualNorm = snap.residualNorm;
state.energy = snap.energy;
state.energyTrend = "flat";
previous = snap.energy;
if isfield(snap, 'hist') && ~isempty(snap.hist)
    previous = snap.hist(end).energy;
end
ratio = snap.energy / max(abs(previous), eps);
if ~all(isfinite(snap.x(:))) || ~isfinite(snap.energy) || ratio >= 50
    state.energyTrend = "exploding";
elseif ratio >= 1.2
    state.energyTrend = "rising_fast";
elseif ratio < 0.95
    state.energyTrend = "falling";
end
state.maxAbsState = max(abs(snap.x(:)));
if any(~isfinite(snap.x(:))), state.maxAbsState = Inf; end
state.stiffnessHint = snap.stiffnessHint;
warnings = string(snap.warnings);
warnings = warnings(strlength(warnings) > 0);
state.nWarnings = numel(warnings);
state.warnings = strjoin(warnings(:), '; ');
state.lastAction = string(snap.lastAction);
state.notes = string(snap.notes);
end
