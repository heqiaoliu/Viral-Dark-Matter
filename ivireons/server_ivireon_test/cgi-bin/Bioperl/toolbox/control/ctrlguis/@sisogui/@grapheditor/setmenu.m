function setmenu(Editor,OnOff,Tag)
% Enables/disables editor menus.

%   $Revision: 1.3.4.3 $  $Date: 2010/05/10 16:59:18 $
%   Copyright 1986-2010 The MathWorks, Inc.

% RE: Menus must be disabled when Editor.SingularLoop=1
PlotAxes = getaxes(Editor.Axes);
uic = get(PlotAxes(1),'uicontextmenu');
if nargin == 3
    % Enable/Disable Particular Menu
    hmenu = findobj(get(uic,'Children'),'Tag',Tag);
    set(hmenu,'Enable',OnOff)
else
    set(get(uic,'Children'),'Enable',OnOff)
end
