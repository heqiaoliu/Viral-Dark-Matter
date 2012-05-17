function addProperty(hThis,propnames)
% Tells code object add property

% Copyright 2004-2009 The MathWorks, Inc.

% Only cell array of strings valid input
if ischar(propnames)
    propnames = {propnames};
end

% Only cell array of strings valid input
if ~iscellstr(propnames)
  error('MATLAB:codetools:codegen',...
        'Invalid input, requires cell array of strings');
end

% Get handles
hMomento = get(hThis,'MomentoRef');
hObj = get(hMomento,'ObjectRef');
if ~ishandle(hObj)
    error('MATLAB:codetools:codegen','Invalid state');
end
hObj = handle(hObj);

% Get list of properties
hPropList = get(hMomento,'PropertyObjects');
for i = 1:length(propnames)
    propname = propnames{i};
    % Get property object
    hProp = findprop(hObj,propname);
    if isempty(hProp)
        error('MATLAB:codetools:codegen','Invalid property %s',propname);
        return;
    end

    % If the property already exists, do not repeat it, but set its "Ignore"
    % flag to false
    if isempty(hPropList)
        hProp = [];
        hPropList = handle([]);
    else
        hProp = find(hPropList,'Name',propname);
    end
    if ~isempty(hProp)
        set(hProp,'Ignore',false);
    else
        % Store property info
        pobj = codegen.momentoproperty;
        set(pobj,'Name',propname);
        set(pobj,'Value',get(hObj,propname));
        set(pobj,'Object',hProp);

        % Update list
        hPropList(end+1) = pobj;
    end
end
set(hMomento,'PropertyObjects',hPropList);