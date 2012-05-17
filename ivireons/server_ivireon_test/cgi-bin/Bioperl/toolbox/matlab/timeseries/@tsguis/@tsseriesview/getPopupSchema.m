function menu = getPopupSchema(this,manager,varargin)
% GETPOPUPSCHEMA Constructs the default popup menu

% Author(s): James G. Owen
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2005/06/27 23:03:56 $

menu = getDefaultPopupSchema(this,manager,varargin{:});

%% Create menus
menuRemoveMissing = com.mathworks.mwswing.MJMenuItem(xlate('Remove Missing Data...'));
menuDetrend = com.mathworks.mwswing.MJMenuItem(xlate('Detrend...'));
menuFilter = com.mathworks.mwswing.MJMenuItem(xlate('Filter...'));
menuInterpolate = com.mathworks.mwswing.MJMenuItem(xlate('Interpolate...'));
menuResample = com.mathworks.mwswing.MJMenuItem(xlate('Resample...'));
menuTimeshift = com.mathworks.mwswing.MJMenuItem(xlate('Synchronize Data...'));
menuSelect = com.mathworks.mwswing.MJMenuItem(xlate('Data Selection...'));

%% Add them
menu.addSeparator;
menu.add(menuRemoveMissing);
menu.add(menuDetrend);
menu.add(menuFilter);
menu.add(menuInterpolate);
menu.addSeparator;
menu.add(menuResample);
menu.add(menuTimeshift);
menu.add(menuSelect);
% menu.addSeparator;
% menu.add(menuExpression);

%% Assign menu callbacks
set(handle(menuTimeshift,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) openshiftdlg(this,manager))
set(handle(menuRemoveMissing,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 4})
set(handle(menuDetrend,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 1})
set(handle(menuFilter,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 2})
set(handle(menuInterpolate,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 3})
set(handle(menuResample,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) tsguis.mergedlg(this))
set(handle(menuSelect,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) openselectdlg(this,manager))


%--------------------------------------------------------------------------
function localPreproc(eventSrc,eventData,this,Ind)


RS = tsguis.preprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);

