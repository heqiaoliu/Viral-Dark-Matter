function eventddg_preclose_callback(dlgH)

% Copyright 2003-2005 The MathWorks, Inc.

if ~ishandle(dlgH)
    return;
end

h = dlgH.getDialogSource;
if ~(isa(h, 'Stateflow.Event')   || ...
     isa(h, 'Stateflow.Trigger') || ...
     isa(h, 'Stateflow.FunctionCall'))
    return;
end

sf('SetDynamicDialog', h.Id, []);
if ~isempty(findstr(h.Tag, '_DDG_INTERMEDIATE_'))
    delete(h);
end