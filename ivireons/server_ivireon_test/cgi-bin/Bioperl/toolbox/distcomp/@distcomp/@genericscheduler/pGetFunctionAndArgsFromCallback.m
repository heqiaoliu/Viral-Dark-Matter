function [fcn, args] = pGetFunctionAndArgsFromCallback(obj, callbackFcn) %#ok<INUSL>
; %#ok Undocumented
%pGetFunctionAndArgsFromCallback split callback into function and args
%

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/05/19 22:45:02 $ 

% If it is a cell array then get the first argument which is a function
% handle or string and subsequent arguments are the 
if iscell(callbackFcn)
    fcn = callbackFcn{1};
    args = callbackFcn(2:end);
else
    fcn = callbackFcn;
    args = {};
end
