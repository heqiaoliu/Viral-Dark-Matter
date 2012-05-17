function currentanalysis_listener(this, eventData)
%CURRENTANALYSIS_LISTENER Listener to the current analysis

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.4 $  $Date: 2004/12/26 22:23:10 $

hFVT = getcomponent(this, 'fvtool');

h  = get(this, 'Handles');
ca = get(hFVT, 'CurrentAnalysis');

if ~isempty(h),
    if isa(ca, 'sigresp.analysisaxis'),
        enab = 'on';
    else
        enab = 'off';
    end

    set([h.toolbar.legend h.toolbar.grid], 'Enable', enab);
end

oldp = get(this, 'AnalysisParameterProps');
delete(oldp);
oldl = get(this, 'ParameterListeners');
delete(oldl);

l = [];
if isempty(ca)
    p = [];
else
    
    hPrm = getparameter(ca, '-all');
    if length(hPrm) == 0,
        p = [];
    end
    
    for indx = 1:length(hPrm),
        hindx = hPrm(indx);
        
        % Get the tag
        tag  = get(hindx, 'Tag');
        name = rmspaces(get(hindx, 'Name'));
        type = get(findprop(hindx, 'Value'), 'DataType');
        
        % Create a property based on the parameter object.
        try,
            p(indx) = schema.prop(this, name, type);
        catch
            p(indx) = schema.prop(this, [name '2'], type);
        end
        
        set(this, name, get(hindx, 'Value'));
        
        % Add preget and postset listeners to link the parameter with the
        % property.
        lindx = [ ...
                handle.listener(this, p(indx), 'PropertyPreGet', ...
                {@lclpreget_listener, hindx}); ...
                handle.listener(this, p(indx), 'PropertyPostSet', ...
                {@lclpostset_listener, hindx}); ...
            ];
        if isempty(l),
            l = lindx;
        else
            l = [l; lindx];
        end
    end
    set(l, 'CallbackTarget', this);
end

set(this, 'AnalysisParameterProps', p);
set(this, 'ParameterListeners', l);

% -------------------------------------------------------------------------
function s = rmspaces(s)

indx = findstr(s, ' ');
s(indx) = [];
openp = strfind(s, '(');
for indx = length(openp):-1:1
    closep = min(strfind(s(openp(indx):end), ')'));
    if isempty(closep)
        s(openp(indx):end) = [];
    else
        s(openp(indx):openp(indx)+closep-1) = [];
    end
end

% -------------------------------------------------------------------------
function lclpreget_listener(this, eventData, hprm)

% When the user tries to get the property, get it from the parameter.  We
% do this in case the set operation caused an error or if the parameter was
% changed from the GUI.
set(this, get(eventData.Source, 'Name'), get(hprm, 'Value'));

% -------------------------------------------------------------------------
function lclpostset_listener(this, eventData, hprm)

% WHen the user tries to set the property set it in the parameterf
setvalue(hprm, get(eventData, 'NewValue'));

% [EOF]
