function y = isDialogVisible(dp,dialogName)
% True if named dialog is undocked, or docked and dialog panel is visible.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:00 $

y = dp.PanelVisible && ...
    any(strcmpi(getDockedDialogNames(dp),dialogName)) || ...
    any(strcmpi(getUndockedDialogNames(dp),dialogName));

