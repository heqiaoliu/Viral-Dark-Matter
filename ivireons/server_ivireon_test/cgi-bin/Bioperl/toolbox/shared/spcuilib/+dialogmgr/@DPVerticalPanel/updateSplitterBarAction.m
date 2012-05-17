function updateSplitterBarAction(dp)
% Change splitter bar affordance based on AutoHide state.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:36 $

splitter = dp.hBodySplitter;

% Update splitter bar icon and callback
if dp.AutoHide
    splitter.Type = 'Bar';
    splitter.CallbackFcn = '';
else
    % Using explicit open/close
    splitter.Type = 'Arrow';
    splitter.CallbackFcn = ''; %xxx @(h,e)toggleDialogPanelVisible(dp);
    
    dlgPanelOnLeft = strcmpi(dp.DockLocation,'left');
    if dp.PanelVisible && dlgPanelOnLeft || ~dp.PanelVisible && ~dlgPanelOnLeft
        adir = 'left';
    else
        adir = 'right';
    end
    splitter.ArrowDirection = adir;
end


