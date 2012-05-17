function hInstall = createGUI(this)
%CREATEGUI 

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:55 $

plan = lineVisual_createGUI(this);

editOptions = uimgr.uimenu('TimeDomainOptions', -inf, uiscopes.message('TimeDomainOptionsLabel'));
editOptions.WidgetProperties = {...
    'callback', @(hco,ev) lclEditOptions(this)};

plan(end+1, :) = {editOptions, 'Base/Menus/View'};

hInstall = uimgr.uiinstaller(plan);

% -------------------------------------------------------------------------
function lclEditOptions(this)

editOptions(this.Application.ExtDriver, this);

% [EOF]
