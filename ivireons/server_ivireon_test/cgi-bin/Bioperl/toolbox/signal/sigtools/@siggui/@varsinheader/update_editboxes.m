function update_editboxes(this)
%UPDATE_EDITBOXES Update the variable name frame

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/12/26 22:22:23 $

lbls = getcurrentlabels(this);
vars = getcurrentvariables(this);

h = get(this, 'Handles');

hLayout = get(this, 'Layout');

% Loop over all the controls
for i = 1:length(lbls)
    
    % If the lbls in the current index is empty do not show it
    if isempty(lbls{i})
        visState = 'Off';
    else
        visState = 'On';
    end
    
    % Update all the labels and editboxes.
    set(h.label(i), ...
        'String', [lbls{i} ':'], ...
        'Visible', visState);
    set(h.length(i), ...
        'String', [lbls{i} xlate(' length:')], ...
        'Visible', visState);
    set(h.varedit(i), ...
        'String', vars.var{i}, ...
        'Visible', visState);
    set(h.lengthedit(i), ...
        'String', vars.length{i}, ...
        'Visible', visState);
    
    hLayout.setconstraints(i, 1, 'MinimumWidth', largestuiwidth(h.label(i)));
    hLayout.setconstraints(i, 3, 'MinimumWidth', largestuiwidth(h.length(i)));
end

% [EOF]
