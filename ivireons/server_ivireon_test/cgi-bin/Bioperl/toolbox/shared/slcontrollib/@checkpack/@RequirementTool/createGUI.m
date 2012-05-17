function plugInGUI = createGUI(this)
%CREATEGUI Create the GUI components

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2.2.1 $  $Date: 2010/06/17 14:13:37 $

%Setappdata for the icons etc we use in this extension

%Register icons with application
icons = load(fullfile(matlabroot,'toolbox','shared','slcontrollib','@checkpack','@RequirementTool','icons'));
flds = fieldnames(icons);
for ct = 1:numel(flds)
   setappdata(this.Application.getGUI, flds{ct}, icons.(flds{ct}))
end

%Edit menu items
mProps = uimgr.uimenu('BoundProperties', 1, ...
   DAStudio.message('SLControllib:checkpack:menuBoundProperties'));
mProps.WidgetProperties = { ...
   'callback', @(hSrc, hData) launch(this,'boundproperties')};
%Group menus
mReq = uimgr.uimenugroup('Bounds',1);
mReq.add(mProps);

% Create plug-in installer
plan = {mReq, 'Base/Menus/Edit'};
plugInGUI = uimgr.uiinstaller(plan);
end