function enableDialogBorderServices(dp,dlgs)
% Update specified dialogs to show/hide DialogBorder services
% in response to a locked or unlocked panel.
%
% If dlgs not passed, all .DockedDialogs are updated.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:45 $

if nargin<2
    dlgs = dp.DockedDialogs;
end
Ndlgs = numel(dlgs);

% Get vector of logical flags, one for each DialogBorder service in use
services = dp.DialogBorderServiceNamesActual;
if dp.PanelLock
    enables = dp.DialogBorderServiceLockedActual;
else
    enables = dp.DialogBorderServiceUnlockedActual;
end

for i = 1:Ndlgs
    % Assess the services from each DialogBorder
    % (Could be a heterogeneous mix of DialogBorders, but typically the
    % set is homogeneous)
    %
    % Services will return false if they are not available
    % Ignore status, simply turn on/off services
    enableService(dlgs(i).DialogBorder,services,enables);
end

