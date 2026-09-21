function tests = test_SupervisorApp
tests = functiontests(localfunctions);
end
function test_componentsAndStart(t)
a=SupervisorApp; cleanup=onCleanup(@() delete(a));
a.UIFigure.Visible='off'; a.Config.sim.tEnd=0.4; a.Config.supervisor.minIntervalSec=0;
names={'StartButton','StopButton','ModeDropDown','AutoCheckBox','StateAxes', ...
    'HealthAxes','ActionLabel','ConfGauge','PlausibleGauge','ReasonText', ...
    'LogTable','InjectBlowupButton','StatusLabel'};
for k=1:numel(names), verifyEqual(t,a.(names{k}).Tag,names{k}); end
feval(a.StartButton.ButtonPushedFcn,a.StartButton,[]);
verifyEqual(t,numel(a.History),2); verifyEqual(t,height(a.LogTable.Data),2);
verifyFalse(t,a.Running); verifyEqual(t,a.StartButton.Enable,matlab.lang.OnOffSwitchState.on);
end
function test_injectAndStop(t)
a=SupervisorApp; cleanup=onCleanup(@() delete(a)); a.UIFigure.Visible='off';
a.Config.sim.tEnd=8; a.Config.supervisor.minIntervalSec=0.1;
a.AutoCheckBox.Value=false;
tm=timer('StartDelay',1,'TimerFcn',@(~,~) feval(a.InjectBlowupButton.ButtonPushedFcn,a.InjectBlowupButton,[]));
timerCleanup=onCleanup(@() disposeTimer(tm)); start(tm);
feval(a.StartButton.ButtonPushedFcn,a.StartButton,[]);
verifyTrue(t,a.History(end).stop); verifyEqual(t,a.History(end).action,"abort");
verifyEqual(t,a.History(end).energyTrend,"exploding");
verifyTrue(t,a.History(end).applied); verifyLessThan(t,a.History(end).t,8);
disposeTimer(tm);
tm2=timer('StartDelay',0.5,'TimerFcn',@(~,~) feval(a.StopButton.ButtonPushedFcn,a.StopButton,[]));
timerCleanup2=onCleanup(@() disposeTimer(tm2)); start(tm2);
feval(a.StartButton.ButtonPushedFcn,a.StartButton,[]);
verifyFalse(t,a.Running);
if ~isempty(a.History), verifyLessThan(t,a.History(end).t,8); end
verifyEqual(t,a.StatusLabel.Text,'Stopped by user');
end
function test_liveMissingKey(t)
a=SupervisorApp; cleanup=onCleanup(@() delete(a)); a.UIFigure.Visible='off';
a.ModeDropDown.Value='live'; a.Config.api.keyEnv='JEV_TEST_NONEXISTENT_KEY_70837';
feval(a.StartButton.ButtonPushedFcn,a.StartButton,[]);
verifyFalse(t,a.Running); verifyEmpty(t,a.History);
verifyTrue(t,contains(a.StatusLabel.Text,'missing API key'));
verifyEqual(t,a.ModeDropDown.Value,'live');
end
function disposeTimer(tm)
if isvalid(tm), stop(tm); delete(tm); end
end
