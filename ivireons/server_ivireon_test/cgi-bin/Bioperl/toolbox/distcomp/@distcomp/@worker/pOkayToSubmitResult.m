function out = pOkayToSubmitResult( obj )
; %#ok Undocumented
%pOkayToSubmitResult 

%   Copyright 2008 The MathWorks, Inc.

proxyWorker = obj.ProxyObject;
out = proxyWorker.okayToSubmitResult;
