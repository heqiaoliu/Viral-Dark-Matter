function plugInGUI = createGUI(this)
%CreateGUI Build and cache UI plug-in for Simulink Source plug-in.
%   This adds the connect/disconnect button and menu to the scope.
%   No install/render needs to be done here.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/04/27 19:54:17 $

% Place=3 for each of these within their respective Source groups
% Placement is just after "import from workspace"
hMenu = uimgr.uimenu('ConnectSLMenu',3,'Connect to &Simulink Signal');
hMenu.WidgetProperties = {...
    'Interruptible', 'off', ...
    'BusyAction', 'cancel', ...
    'callback', @(hco,ev)connectToDataSource(this.Application, this)};
                
hButton = uimgr.spctoggletool('ConnectSLButton',3);
hButton.IconAppData = {'connect_sl','disconnect_sl'};
hButton.WidgetProperties = {...
    'Interruptible', 'off', ...
    'BusyAction', 'cancel', ...
    'Tooltips', {'Disconnect from Simulink signal','Connect to Simulink signal'}, ...
    'offcall',@(hco,ev) releaseData(this.Application), ...
    'oncall', @(hco,ev) connectToDataSource( this.Application, this)};

% Create plug-in installer
plan = {hMenu,'Base/Menus/File/Sources';
        hButton,'Base/Toolbars/Main/Sources'};
plugInGUI = uimgr.uiinstaller(plan);

end

% [EOF]
