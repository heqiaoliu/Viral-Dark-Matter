function set_selectednames(this, winnames, index)
%SET_SELECTEDNAMES Set the selected names in the combo box
%   Set the 'String' property of the combo with the cell array 
%   stored in WINNAMES. The window editable in the combo is defined
%   by INDEX.

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/12/26 22:22:36 $

if ~isrendered(this),
    return
end

h = get(this, 'Handles');

% Update the combo box
if isempty(winnames{1}),
    % Disable the component
    set(this, 'Enable', 'off');
    set(h.winname, 'String', {''}, 'Max', 0, 'Value', 1);
else,
    % Enable the component
    set(this, 'Enable', 'on');
    set(h.winname, 'Value', index, 'String', winnames, 'Max', 1);
end

% [EOF]
