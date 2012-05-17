function hProp = getProperty(hThis,propname)
% Returns the property object for specified by "propname"

% Copyright 2007 The MathWorks, Inc.

% Only take strings
if ~ischar(propname)
    error('MATLAB:codetools:codegen',...
        'Invalid input, string required');
end

% Get handles
hMomento = get(hThis,'MomentoRef');

hPropList = get(hMomento,'PropertyObjects');
hProp = find(hPropList,'Name',propname,'Ignore',false);


