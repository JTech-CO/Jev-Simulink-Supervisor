function [decision, diag] = jevClient(state, questions, cfg)
diag = struct('reason',"",'ok',false);
started = tic;
decision = struct('action',"continue",'actionP',struct(), ...
    'actionConf',0,'healthScore',0,'healthConf',0,'healthP',struct(), ...
    'plausible',1,'raw',struct(),'source',"error",'latencyMs',0);
if string(cfg.api.mode) == "mock"
    decision = mockJev(state); diag.ok = true; return
end
if string(cfg.api.mode) ~= "live"
    diag.reason = "invalid_api_mode"; return
end
key = getenv(cfg.api.keyEnv);
if isempty(strtrim(key))
    diag.reason = "missing_api_key"; return
end
try
    options = weboptions('MediaType','application/json','ContentType','json', ...
        'KeyName','Authorization','KeyValue',['Bearer ' key], ...
        'Timeout',cfg.api.timeoutSec);
    raw = webwrite(char(cfg.api.url),struct('model',cfg.api.model, ...
        'state',state,'questions',questions),options);
    decision = normalizeJevResponse(raw);
    diag.ok = true;
catch ME
    % Do not log exception text: HTTP diagnostics may contain credentials.
    diag.reason = "live_request_failed:" + string(ME.identifier);
end
decision.latencyMs = toc(started)*1000;
end
