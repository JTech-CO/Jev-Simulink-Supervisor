function sim = makeDemoPlant(cfg)
sim = struct('t',0,'x',cfg.sim.x0,'nSteps',0,'solver',cfg.sim.solver, ...
    'relTol',cfg.sim.relTol,'absTol',cfg.sim.absTol,'stop',false, ...
    'lastAction',"continue",'warnings',strings(0,1));
sim.rhs = @(t,x) [x(2); cfg.sim.mu*(1-x(1)^2)*x(2)-x(1)];
sim.times = 0; sim.states = sim.x(:).';
end
