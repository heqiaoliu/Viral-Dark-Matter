function mRoot = addTsMenu(this,menuType,varargin)
%ADDSIMMENU  Install @timeplot-specific menus.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2005/06/27 23:03:41 $

AxGrid = this.AxesGrid;
mRoot = AxGrid.findMenu(menuType);  % search for specified menu (HOLD support)
if ~isempty(mRoot)
    return
end

switch menuType
    case 'selectrule'
        % Show input signal
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label','Select Data...','Tag','selectrule',...
            'Callback',@(es,ed) openselectdlg(this),varargin{:});
    case 'merge'
        % Show input signal
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label','Resample Data...','Tag','merge',...
            'Callback',@(es,ed) tsguis.mergedlg(this),varargin{:});
    case 'removemissingdata'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label','Remove Missing Data...','Tag','removemissingdata',...
            'Callback',{@localPreproc this 4});
    case 'detrend'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label','Detrend...','Tag','detrend',...
            'Callback',{@localPreproc this 1});
    case 'filter'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label','Filter...','Tag','filter',...
            'Callback',{@localPreproc this 2});
    case 'interpolate'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label','Interpolate...','Tag','interpolate',...
            'Callback',{@localPreproc this 3});
    case {'remove','delete','keep','newevent'}
        this.addlisteners(handle.listener(this,this.findprop('Responses'),'PropertyPostSet',...
            {@localSyncSelectionMenus this menuType}));
end

%--------------------------------------------------------------------------
function localSyncSelectionMenus(eventSrc, eventData, h, menutype)

%% Listener callback which installs context menus for selected curves on
%% each wave. Note that this listener must be managed at the top level
%% (i.e., can't just be at the view level) since the menu callback needs
%% access to both the data and the view handles
for k=1:length(h.Responses)
    h.Responses(k).View.addMenu(h,menutype);
end

%--------------------------------------------------------------------------
function localPreproc(eventSrc,eventData,this,Ind)


RS = tsguis.preprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);


