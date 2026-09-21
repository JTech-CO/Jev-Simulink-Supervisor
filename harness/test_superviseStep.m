function tests = test_superviseStep
tests = functiontests(localfunctions);
end
function test_rules(t)
cfg = defaultConfig(); f = fixtures();
s = struct('solver',"ode45",'relTol',1e-3,'absTol',1e-6,'nSteps',20);
p = superviseStep(mockJev(f.healthy),s,cfg,[]);
verifyTrue(t,p.apply); verifyEqual(t,p.action,"continue"); verifyFalse(t,p.simUpdate.stop);
d = mockJev(f.stiffOnOde45);
verifyEqual(t,d.action,"switch_solver");
p = superviseStep(d,s,cfg,[]);
verifyFalse(t,p.apply); verifyEqual(t,p.action,"continue"); verifyEqual(t,p.reason,"low_confidence");
cfg.supervisor.autoApplyMinConf = 0.60;
p = superviseStep(d,s,cfg,[]);
verifyTrue(t,p.apply); verifyEqual(t,p.simUpdate.solver,"ode15s");
h = struct('applied',true,'action',"switch_solver",'nSteps',10);
verifyEqual(t,superviseStep(d,s,cfg,h).reason,"cooldown");
s.nSteps = 50;
verifyTrue(t,superviseStep(d,s,cfg,h).apply);
p = superviseStep(mockJev(f.blowup),s,cfg,h);
verifyTrue(t,p.simUpdate.stop);
d.action = "tighten"; d.actionConf = 0.9; s.absTol = 1e-9;
p = superviseStep(d,s,cfg,[]);
verifyEqual(t,p.simUpdate.absTol,1e-9); verifyEqual(t,p.simUpdate.relTol,1e-4,'AbsTol',eps);
sim = struct('stop',false); [sim,cfg] = applyAction(sim,cfg,p);
verifyEqual(t,sim.relTol,cfg.sim.relTol);
end
function test_abortGates(t)
c = defaultConfig(); f = fixtures(); d = mockJev(f.blowup);
s = struct('solver',"ode45",'relTol',1e-3,'absTol',1e-6,'nSteps',1);
d.actionConf=0; d.plausible=0.9; d.healthScore=3;
verifyTrue(t,superviseStep(d,s,c,[]).simUpdate.stop);
d.healthScore=0; d.plausible=0.08;
verifyTrue(t,superviseStep(d,s,c,[]).simUpdate.stop);
d.plausible=0.9;
verifyFalse(t,superviseStep(d,s,c,[]).simUpdate.stop);
end
