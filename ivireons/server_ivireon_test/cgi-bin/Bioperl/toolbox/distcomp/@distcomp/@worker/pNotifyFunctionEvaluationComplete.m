function pNotifyFunctionEvaluationComplete( obj )
; %#ok Undocumented
%pNotifyFunctionEvaluationComplete 

%   Copyright 2008 The MathWorks, Inc.

proxyWorker = obj.ProxyObject;
proxyWorker.notifyFunctionEvaluationComplete();
