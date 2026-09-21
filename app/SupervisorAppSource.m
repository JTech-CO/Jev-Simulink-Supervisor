classdef SupervisorAppSource < matlab.apps.AppBase
    % Reviewable build source; buildSupervisorApp creates SupervisorApp.mlapp.
    properties (Access = public)
        UIFigure matlab.ui.Figure
        StartButton matlab.ui.control.Button
        StopButton matlab.ui.control.Button
        InjectBlowupButton matlab.ui.control.Button
        ModeDropDown matlab.ui.control.DropDown
        AutoCheckBox matlab.ui.control.CheckBox
        StateAxes matlab.ui.control.UIAxes
        HealthAxes matlab.ui.control.UIAxes
        ActionLabel matlab.ui.control.Label
        ConfGauge matlab.ui.control.Gauge
        PlausibleGauge matlab.ui.control.Gauge
        ReasonText matlab.ui.control.TextArea
        LogTable matlab.ui.control.Table
        StatusLabel matlab.ui.control.Label
    end
    properties (Access = public)
        Running = false
        InjectBlowup = false
        Config = defaultConfig()
        History = struct([])
    end
    methods (Access = public)
        function refresh(app,sim,hist,decision,policy,cfg)
            SupervisorApp_logic.refresh(app,sim,hist,decision,policy,cfg);
        end
    end
    methods (Access = private)
        function StartButtonPushed(app, event)
            SupervisorApp_logic.start(app);
        end
        function StopButtonPushed(app, event)
            SupervisorApp_logic.stop(app);
        end
        function InjectBlowupButtonPushed(app, event)
            SupervisorApp_logic.inject(app);
        end
        function UIFigureCloseRequest(app, event)
            app.Running = false;
            delete(app);
        end
        function createComponents(app)
            app.UIFigure = uifigure('Visible','off','Position',[100 100 1080 720], ...
                'Name','Jev-Simulink Supervisor','Tag','UIFigure');
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app,@UIFigureCloseRequest,true);
            app.StartButton = uibutton(app.UIFigure,'Position',[24 665 100 32],'Text','Start','Tag','StartButton');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app,@StartButtonPushed,true);
            app.StopButton = uibutton(app.UIFigure,'Position',[136 665 100 32],'Text','Stop','Tag','StopButton');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app,@StopButtonPushed,true);
            app.InjectBlowupButton = uibutton(app.UIFigure,'Position',[248 665 145 32],'Text','InjectBlowup','Tag','InjectBlowupButton');
            app.InjectBlowupButton.ButtonPushedFcn = createCallbackFcn(app,@InjectBlowupButtonPushed,true);
            app.ModeDropDown = uidropdown(app.UIFigure,'Position',[425 665 110 32],'Items',{'mock','live'},'Tag','ModeDropDown');
            app.AutoCheckBox = uicheckbox(app.UIFigure,'Position',[555 665 170 32],'Text','Auto apply','Value',true,'Tag','AutoCheckBox');
            app.StatusLabel = uilabel(app.UIFigure,'Position',[24 622 1020 28], ...
                'Text','Ready | mock | ode45 | RelTol 0.001 | AbsTol 1e-06','Tag','StatusLabel');
            app.StateAxes = uiaxes(app.UIFigure,'Position',[24 350 610 260],'Tag','StateAxes');
            title(app.StateAxes,'Van der Pol | mu = 1000'); xlabel(app.StateAxes,'Time (s)'); ylabel(app.StateAxes,'State');
            app.HealthAxes = uiaxes(app.UIFigure,'Position',[24 100 610 240],'Tag','HealthAxes');
            title(app.HealthAxes,'Numerical health'); xlabel(app.HealthAxes,'Time (s)'); ylim(app.HealthAxes,[0 3]);
            app.ActionLabel = uilabel(app.UIFigure,'Position',[675 568 360 40],'Text','continue','FontSize',24,'Tag','ActionLabel');
            app.ConfGauge = uigauge(app.UIFigure,'circular','Position',[680 425 140 140],'Limits',[0 1],'MajorTicks',[0 0.5 1],'MinorTicks',0:0.1:1,'Tag','ConfGauge');
            app.PlausibleGauge = uigauge(app.UIFigure,'circular','Position',[885 425 140 140],'Limits',[0 1],'MajorTicks',[0 0.5 1],'MinorTicks',0:0.1:1,'Tag','PlausibleGauge');
            uilabel(app.UIFigure,'Position',[680 398 165 22],'Text','Action confidence','Tag','ConfLabel');
            uilabel(app.UIFigure,'Position',[885 398 160 22],'Text','Physically plausible','Tag','PlausibleLabel');
            app.ReasonText = uitextarea(app.UIFigure,'Position',[675 330 360 60],'Editable','off','Value',{'Ready'},'Tag','ReasonText');
            app.LogTable = uitable(app.UIFigure,'Position',[655 65 400 250],'Tag','LogTable', ...
                'ColumnName',{'t','action','conf','health','plausible','applied'}, ...
                'ColumnWidth',{40,105,45,45,65,55});
            app.UIFigure.Visible = 'on';
        end
    end
    methods (Access = public)
        function app = SupervisorAppSource
            createComponents(app);
            registerApp(app,app.UIFigure);
            if nargout == 0, clear app; end
        end
        function delete(app)
            delete(app.UIFigure);
        end
    end
end
