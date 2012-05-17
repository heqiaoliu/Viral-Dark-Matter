function addListeners(this)
%ADDLISTENERS  Installs listeners for automated tuning panel

%   Author(s): R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/04/21 03:07:34 $

% Listen to LoopData object
Listeners = [handle.listener(this.LoopData,'ConfigChanged',@LocalSync) ; ...
             handle.listener(this.LoopData,'LoopDataChanged',@LocalRefresh); ...
             handle.listener(this.Preference,this.Preference.findprop('PadeOrder'), ...
             'PropertyPostSet',@LocalRefreshSpecPanel)];
set(Listeners,'CallbackTarget',this);
this.Listeners = Listeners;
this.addVisibilityListener;

% ------------------------------------------------------------------------%
% Function: LocalSync
% Purpose:  Synchronize compensator list when LoopData changes its configuration
% ------------------------------------------------------------------------%
function LocalSync(this, event) %#ok<INUSD>
% Resync compensator list 
this.utSyncCompList;
% refresh panel display
this.refreshPanel;

% ------------------------------------------------------------------------%
% Function: LocalRefresh
% Purpose:  Refresh panel display when LoopData changes
% ------------------------------------------------------------------------%
function LocalRefresh(this, event) %#ok<INUSD>
% refresh panel display
this.IsOpenLoopPlantDirty = true;
% refresh panel display
this.refreshPanel;


% ------------------------------------------------------------------------%
% Function: LocalRefreshSpecPanel
% Purpose:  Refresh panel display when Pade Order changes
% ------------------------------------------------------------------------%
% Revisit Should this listener be added separately?
function LocalRefreshSpecPanel(this, event) %#ok<INUSD>
if this.isVisible
    this.refreshSpecPanel(true);
end