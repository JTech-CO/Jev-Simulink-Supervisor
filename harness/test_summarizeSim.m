function tests = test_summarizeSim
tests = functiontests(localfunctions);
end
function test_trends(testCase)
s = struct('t',1,'x',[2;0],'solver',"ode45",'relTol',1e-3, ...
    'absTol',1e-6,'residualNorm',2,'energy',2,'stiffnessHint',3000, ...
    'warnings',["first","second"],'lastAction',"continue",'notes',"demo");
a = summarizeSim(s);
verifyEqual(testCase,a.energyTrend,"flat");
verifyEqual(testCase,a.nWarnings,2);
verifyEqual(testCase,a.relTol,"0.001");
s.hist = struct('energy',2); s.energy = 3;
verifyEqual(testCase,summarizeSim(s).energyTrend,"rising_fast");
s.energy = 200;
verifyEqual(testCase,summarizeSim(s).energyTrend,"exploding");
s.energy = 1;
verifyEqual(testCase,summarizeSim(s).energyTrend,"falling");
s.x(1) = NaN;
verifyEqual(testCase,summarizeSim(s).energyTrend,"exploding");
verifyWarningFree(testCase,@() jsonencode(a));
end
