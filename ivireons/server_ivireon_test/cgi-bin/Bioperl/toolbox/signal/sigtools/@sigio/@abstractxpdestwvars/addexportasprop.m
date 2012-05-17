function addexportasprop(h)
%ADDEXPORTASPROP Add an 'ExportAs' dynamic property.

% This should be a private method

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/04/11 18:44:14 $

info = exportinfo(h.data);

if isfield(info, 'exportas'),
    addxpasdynprop(h,info);
    
    if isfield(info,'exportas'),
        enab = 'on';
    else
        enab = 'off';
    end
    
    % Turn on/off the 'ExportAs' dynamic property
    % enabdynprop(h, 'ExportAs', getexportasinfo(h));
    enabdynprop(h, 'ExportAs', enab);
end

%--------------------------------------------------------------------
function addxpasdynprop(h,info)

str = 'signalsigioexportas';

% Create an enumerated data type using the tags of each type 
if isempty(findtype(str)),
    schema.EnumType(str, info.exportas.tags); 
end 

% Add a property for the current filter type
p = schema.prop(h, 'ExportAs', str);

% Create a listener to the ExportAs property
ealis  = handle.listener(h, h.findprop('ExportAs'), ...
    'PropertyPostSet', @prop_listener);
set(ealis, 'CallbackTarget', h);
setappdata(h, 'listeners', ealis);


% -------------------------------------------------------
function prop_listener(h, eventData)

nval = get(eventData, 'NewValue');
if strcmpi(nval,'Objects'),
    parse4obj(h);
else
    parse4vec(h);
end

% [EOF]