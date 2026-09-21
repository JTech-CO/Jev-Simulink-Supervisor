function buildSupervisorApp()
% Build editable App Designer data using the installed R2025a serializer.
folder = fileparts(mfilename('fullpath'));
app = SupervisorAppSource();
cleanup = onCleanup(@() delete(app));
app.UIFigure.Visible = 'off';
code = fileread(fullfile(folder,'SupervisorAppSource.m'));
code = strrep(code,'SupervisorAppSource','SupervisorApp');
components = findall(app.UIFigure);
for k=1:numel(components)
    item = components(k);
    if ~isprop(item,'Tag') || isempty(item.Tag), continue; end
    if ~isprop(item,'DesignTimeProperties'), addprop(item,'DesignTimeProperties'); end
    item.DesignTimeProperties = struct('CodeName',item.Tag,'GroupId','', ...
        'ComponentCode',{{}},'ImageRelativePath','','DirtyProps',struct());
end
serializer = appdesigner.internal.serialization.MLAPPSerializer( ...
    fullfile(folder,'SupervisorApp.mlapp'),app.UIFigure);
serializer.OverwriteTargetFile = true;
serializer.MatlabCodeText = code;
serializer.ClassName = 'SupervisorApp';
serializer.Metadata = appdesigner.internal.model.MetadataModel();
% Retain editable properties/methods and callback bodies in the designer.
parts = regexp(code,'(?s)(    properties \(Access = public\)\n        Running.*?)(?=    methods \(Access = private\))','tokens','once');
serializer.EditableSectionCode = cellstr(splitlines(string(parts{1})));
names = {'StartButtonPushed','StopButtonPushed','InjectBlowupButtonPushed','UIFigureCloseRequest'};
callbacks = struct('Name',{},'Code',{});
for k=1:numel(names)
    body = regexp(code,['(?s)function ' names{k} '\(app, event\)\n(.*?)        end'],'tokens','once');
    callbacks(k).Name = names{k};
    callbacks(k).Code = cellstr(splitlines(string(body{1})));
    callbacks(k).Args = {'app','event'};
end
serializer.Callbacks = callbacks;
app.StartButton.ButtonPushedFcn = 'StartButtonPushed';
app.StopButton.ButtonPushedFcn = 'StopButtonPushed';
app.InjectBlowupButton.ButtonPushedFcn = 'InjectBlowupButtonPushed';
app.UIFigure.CloseRequestFcn = 'UIFigureCloseRequest';
serializer.save();
end
