function targetnames_listener(hXP, eventData);
%TARGETNAMES_LISTENER Listener to the TargetNames property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/05/08 06:41:22 $

h  = get(hXP,'Handles');
if iscoeffs(hXP),
    targ = get(hXP,'TargetNames');
else
    targ = get(hXP, 'ObjectTargetNames');
end

% If the # of edit boxes does not match the number of targetnames, rerender.
if length(h.edit) ~= max([length(get(hXP,'TargetNames')), length(get(hXP,'ObjectTargetNames'))]),
    render_editboxes(hXP);
end

update_popup(hXP);
update_editboxes(hXP);

set(hXP, 'isApplied', 0);

% [EOF]
