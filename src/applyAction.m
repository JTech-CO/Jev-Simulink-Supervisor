function [sim, cfg] = applyAction(sim, cfg, policy)
if ~policy.apply, return; end
cfg.sim.solver = policy.simUpdate.solver;
cfg.sim.relTol = policy.simUpdate.relTol;
cfg.sim.absTol = policy.simUpdate.absTol;
sim.solver = cfg.sim.solver;
sim.relTol = cfg.sim.relTol;
sim.absTol = cfg.sim.absTol;
sim.stop = sim.stop || policy.simUpdate.stop;
sim.lastAction = policy.action;
end
