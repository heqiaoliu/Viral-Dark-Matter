function mdldiscdemoscript(action)

% Copyright 2005-2008 The MathWorks, Inc.

persistent mdldiscwindow;

if nargin ~= 1
    error('mdldiscdemoscript must be called with an action');
end

switch action
    case 'open'
        f14;
    case 'opendisc'
        mdldiscwindow = slmdldiscui('f14');
    case 'viewnext'
        mdldiscwindow.setRunMatlabSync(0);
        mdldiscwindow.setTreeNodeAt(1);
        mdldiscwindow.setRunMatlabSync(1);
    case 'disccurr'
        mdldiscwindow.setRunMatlabSync(0);
        mdldiscwindow.fMdlDisc.allEvaluated = true;
        mdldiscwindow.click(mdldiscwindow.getToolButtonAt(7));
        mdldiscwindow.setTreeNodeAt(0);
        mdldiscwindow.setRunMatlabSync(1);
    case 'actmdl'
        mdldiscwindow.setRunMatlabSync(0);
        mdldiscwindow.setTreeNodeAt(1);
        open_system(sprintf('f14/Actuator\nModel'));
        mdldiscwindow.setRunMatlabSync(1);
    otherwise
        fprintf('Unknown action %s in mdldiscdemoscript\n',action);
end