function plugInGUI = createGUI(this)  
%CreateGUI Build and cache UI plug-in for File Source plug-in.
%   This adds the connect button and menu to the scope.
%   No install/render needs to be done here.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/08/24 15:06:27 $

% Place=1 for each of these within their respective Source groups
% Placement is just after "new"

mConnectFile = uimgr.uimenu('ConnectFileMenu',1,'&Open...');
mConnectFile.WidgetProperties = {...
    'accel','o', ...
    'callback', @(hco,ev)connectToDataSource(this.Application,this)};
                 
bConnectFile = uimgr.uipushtool('ConnectFileButton',1);
bConnectFile.IconAppData = 'openFolder';
bConnectFile.WidgetProperties = {...
    'busyaction','cancel', ...
    'tooltip','Open file', ...
    'click', @(hco,ev)connectToDataSource(this.Application, this)};

% Create plug-in installer
plan = {mConnectFile,'Base/Menus/File/Sources';
        bConnectFile,'Base/Toolbars/Main/Sources'};

plugInGUI = uimgr.uiinstaller(plan);


% [EOF]
