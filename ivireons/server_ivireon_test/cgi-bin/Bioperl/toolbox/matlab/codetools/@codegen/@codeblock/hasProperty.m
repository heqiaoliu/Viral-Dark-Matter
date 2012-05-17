function [bool] = hasProperty(hThis,propname)
% Return true is recorded by code object

% Copyright 2003-2005 The MathWorks, Inc.

bool = false;

% Only take strings
if ~isstr(propname)
    error('MATLAB:codetools:codegen',...
        'Invalid input, string required');
end

% Get handles
hMomento = get(hThis,'MomentoRef');

hPropList = get(hMomento,'PropertyObjects');
bool = ~isempty(find(hPropList,'Name',propname,'Ignore',false));


