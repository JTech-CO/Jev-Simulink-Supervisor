function hist = runDemoLoop(cfg, appHandle)
if nargin < 2, appHandle = []; end
hist = struct([]);
hasApp = ~isempty(appHandle);
if string(cfg.api.mode)=="live" && isempty(strtrim(getenv(cfg.api.keyEnv)))
    if hasApp
        appHandle.StatusLabel.Text = 'ERROR: missing API key';
        appHandle.Running = false; return
    end
    error('Jev:MissingAPIKey','Live mode requires the configured key environment variable.');
end
assert(any(string(cfg.api.mode)==["mock","live"]),'Jev:InvalidMode','Invalid API mode.');
validateattributes(cfg.sim.dt,{'numeric'},{'scalar','positive','finite'});
validateattributes(cfg.sim.tEnd,{'numeric'},{'scalar','positive','finite'});
validateattributes(cfg.supervisor.intervalSteps,{'numeric'},{'scalar','integer','positive'});
sim = makeDemoPlant(cfg);
questions = jevQuestions();
lastCall = []; decisions = {}; policies = {}; diagnostics = {};
while sim.t < cfg.sim.tEnd && ~sim.stop
    drawnow limitrate
    if hasApp && (~isvalid(appHandle) || ~appHandle.Running), break; end
    sim.warnings = strings(0,1);
    % Supervision is wall-clock throttled, while allowing responsive Stop.
    if ~isempty(lastCall)
        while toc(lastCall) < cfg.supervisor.minIntervalSec
            pause(min(0.02,max(0,cfg.supervisor.minIntervalSec-toc(lastCall))));
            drawnow limitrate
            if hasApp && (~isvalid(appHandle) || ~appHandle.Running), returnWithLogs(); return; end
        end
    end
    previousEnergy = 0.5*sum(sim.x.^2);
    finish = min(cfg.sim.tEnd,sim.t+cfg.supervisor.intervalSteps*cfg.sim.dt);
    lastwarn('');
    options = odeset('RelTol',cfg.sim.relTol,'AbsTol',cfg.sim.absTol,'OutputFcn',@output);
    try
        solver = str2func(char(cfg.sim.solver));
        [ts,xs] = solver(sim.rhs,[sim.t finish],sim.x,options);
        if ~isempty(ts)
            sim.times = [sim.times; ts(2:end)];
            sim.states = [sim.states; xs(2:end,:)];
            sim.t = ts(end); sim.x = xs(end,:).';
        end
        [warningMessage,~] = lastwarn;
        if ~isempty(warningMessage), sim.warnings(end+1) = string(warningMessage); end
        if sim.t < finish && ~(hasApp && (~isvalid(appHandle) || ~appHandle.Running))
            sim.stop = true; sim.warnings(end+1) = "Integration stopped before chunk end";
        end
    catch ME
        sim.warnings(end+1) = string(ME.message); sim.stop = true;
    end
    if hasApp && (~isvalid(appHandle) || ~appHandle.Running), break; end
    sim.nSteps = sim.nSteps + cfg.supervisor.intervalSteps;
    if hasApp && appHandle.InjectBlowup
        sim.x = sim.x*10; appHandle.InjectBlowup = false;
        sim.states(end,:) = sim.x.';
    end
    snap = sim;
    snap.xdot = sim.rhs(sim.t,sim.x); snap.u = [];
    snap.residualNorm = norm(snap.xdot);
    snap.energy = 0.5*sum(sim.x.^2);
    J = [0 1; -2*cfg.sim.mu*sim.x(1)*sim.x(2)-1 cfg.sim.mu*(1-sim.x(1)^2)];
    if all(isfinite(J(:))), snap.stiffnessHint = max(abs(eig(J))); else, snap.stiffnessHint = Inf; end
    snap.notes = "Van der Pol mu=1000 stiff demo";
    snap.hist = struct('energy',previousEnergy);
    state = summarizeSim(snap);
    lastCall = tic;
    [decision,diag] = jevClient(state,questions,cfg);
    policy = superviseStep(decision,snap,cfg,hist);
    if hasApp && ~appHandle.AutoCheckBox.Value && policy.action ~= "abort"
        policy.apply = false; policy.action = "continue"; policy.reason = "auto_disabled";
    end
    [sim,cfg] = applyAction(sim,cfg,policy);
    row = appendLog(struct(),snap,state,decision,policy);
    hist = [hist; row]; %#ok<AGROW>
    decisions{end+1} = decision; policies{end+1} = policy; diagnostics{end+1} = diag; %#ok<AGROW>
    if hasApp, appHandle.refresh(sim,hist,decision,policy,cfg); end
    drawnow limitrate
end
returnWithLogs();

    function status = output(~,~,~)
        drawnow limitrate
        status = hasApp && (~isvalid(appHandle) || ~appHandle.Running);
    end
    function returnWithLogs()
        root = fileparts(fileparts(mfilename('fullpath')));
        logDir = fullfile(root,'logs');
        if ~exist(logDir,'dir'), mkdir(logDir); end
        base = tempname(logDir);
        if ~isempty(hist), writetable(struct2table(hist),[base '.csv']); end
        save([base '.mat'],'hist','decisions','policies','diagnostics','cfg');
        if hasApp && isvalid(appHandle), appHandle.Running = false; end
    end
end
