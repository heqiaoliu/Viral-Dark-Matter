function paramNames = getParamNames(this)
%GETPARAMNAMES Get the paramNames.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/01/20 15:36:06 $

if isa(this.privWindow, 'sigwin.functiondefined')
    paramNames = {'FunctionName', 'Parameter'};
else
    paramNames = getparamnames(this.privWindow);
end

if ~iscell(paramNames)
    paramNames = {paramNames ''};
elseif length(paramNames) == 1
    paramNames = {paramNames{1} ''};
end

% [EOF]
