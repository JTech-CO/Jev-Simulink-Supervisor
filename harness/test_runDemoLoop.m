function tests = test_runDemoLoop
tests = functiontests(localfunctions);
end
function test_headless(t)
c=defaultConfig(); c.sim.tEnd=0.6; c.supervisor.minIntervalSec=0;
h=runDemoLoop(c);
verifyEqual(t,numel(h),3); verifyEqual(t,h(end).t,0.6,'AbsTol',1e-12);
verifyEqual(t,h(1).action,"switch_solver"); verifyFalse(t,h(1).applied);
verifyEqual(t,h(end).solver,"ode45");
c.supervisor.autoApplyMinConf=0.6;
h=runDemoLoop(c,[]);
verifyEqual(t,h(2).solver,"ode15s"); verifyTrue(t,h(1).applied);
end
