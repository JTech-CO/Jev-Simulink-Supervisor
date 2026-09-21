function cfg = defaultConfig()
cfg.api.mode = "mock";
cfg.api.url = "https://api.typesafe.ai/v1/systemone";
cfg.api.model = "jev-latest";
cfg.api.keyEnv = "TYPESAFE_API_KEY";
cfg.api.timeoutSec = 8;

cfg.supervisor.intervalSteps = 20;
cfg.supervisor.minIntervalSec = 0.4;
cfg.supervisor.autoApplyMinConf = 0.80;
cfg.supervisor.abortMinConf = 0.70;
cfg.supervisor.noulAbort = 0.85;
cfg.supervisor.healthAbortScore = 2.5;
cfg.supervisor.cooldownSteps = 40;
cfg.supervisor.hysteresis = 0.08;

cfg.sim.tEnd = 8;
cfg.sim.dt = 0.01;
cfg.sim.solver = "ode45";
cfg.sim.relTol = 1e-3;
cfg.sim.absTol = 1e-6;
cfg.sim.mu = 1000;
cfg.sim.x0 = [2; 0];
end
