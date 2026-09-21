classdef SupervisorApp_logic
    % Shared callbacks for the App Designer app.
    methods (Static)
        function start(app)
            if app.Running, return; end
            cfg = app.Config; cfg.api.mode = string(app.ModeDropDown.Value);
            app.Running = true; app.InjectBlowup = false;
            app.StartButton.Enable = 'off'; app.ModeDropDown.Enable = 'off';
            app.History = struct([]); app.LogTable.Data = {};
            cla(app.StateAxes); cla(app.HealthAxes);
            cleanup = onCleanup(@() SupervisorApp_logic.finish(app));
            try
                app.History = runDemoLoop(cfg,app);
            catch ME
                if isvalid(app), app.StatusLabel.Text = ['ERROR: ' ME.message]; end
            end
        end
        function finish(app)
            if ~isvalid(app), return; end
            app.Running = false;
            app.StartButton.Enable = 'on'; app.ModeDropDown.Enable = 'on';
        end
        function stop(app)
            app.Running = false; app.StatusLabel.Text = 'Stopped by user';
        end
        function inject(app)
            if app.Running, app.InjectBlowup = true; end
        end
        function refresh(app,sim,hist,decision,policy,cfg)
            app.History = hist;
            plot(app.StateAxes,sim.times,sim.states);
            legend(app.StateAxes,{'x1','x2'},'Location','best');
            plot(app.HealthAxes,[hist.t],[hist.health],'-o');
            ylim(app.HealthAxes,[0 3]);
            app.ActionLabel.Text = char(decision.action);
            app.ConfGauge.Value = decision.actionConf;
            app.PlausibleGauge.Value = decision.plausible;
            app.ReasonText.Value = cellstr(policy.reason);
            tableData = struct2table(hist);
            app.LogTable.Data = tableData(:,{'t','action','conf','health','plausible','applied'});
            status = sprintf('%s | %s | RelTol %.1g | AbsTol %.1g', ...
                cfg.api.mode,cfg.sim.solver,cfg.sim.relTol,cfg.sim.absTol);
            if sim.stop, status = ['Stopped | ' status];
            elseif sim.t >= cfg.sim.tEnd, status = ['Completed | ' status]; end
            app.StatusLabel.Text = status;
        end
    end
end
