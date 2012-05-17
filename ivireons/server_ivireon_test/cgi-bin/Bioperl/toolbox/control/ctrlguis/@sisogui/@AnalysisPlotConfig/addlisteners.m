function addlisteners(this)
%ADDLISTENERS  Installs listeners for response configuration dialog.

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/09/15 20:36:41 $

sisodb = this.SISODB;
if isempty(sisodb.AnalysisView)
    this.Listeners = [handle.listener(sisodb,sisodb.findprop('AnalysisView'),...
        'PropertyPostSet',{@LocalCreateViewsListener this});...
         handle.listener(this.SISODB.LoopData,'ConfigChanged',{@LocalReset this})];
else
    LocalCreateViewsListener([],[],this);
end


%-------------------------Callback Functions------------------------

% ------------------------------------------------------------------------%
% Function: LocalCreateViewsListener
% Purpose:  Add listeners to Views
% ------------------------------------------------------------------------%
function LocalCreateViewsListener(hsrc,event,this)
Viewer = this.SISODB.AnalysisView;
Listeners = handle.listener(Viewer,Viewer.findprop('Views'),...
    'PropertyPostSet',{@LocalUpdateDialog this});
this.Listeners = [this.Listeners;Listeners];
this.updateData;
this.createVisibilityListeners;

% ------------------------------------------------------------------------%
% Function: LocalUpdateDialog
% Purpose:  Update Dialog
% ------------------------------------------------------------------------%
function LocalUpdateDialog(hsrc,eventdata,this)
this.updateData;
this.createVisibilityListeners;

% ------------------------------------------------------------------------%
% Function: LocalDestroy
% Purpose:  Close and dispose of dialog
% ------------------------------------------------------------------------%
function LocalDestroy(hsrc,event,this)
% Close editor
Fig = this.Figure;
if ~isempty(Fig) 
   delete(Fig);
end

% ------------------------------------------------------------------------%
% Function: LocalReset
% Purpose: Reset data when configuration is changed
% ------------------------------------------------------------------------%
function LocalReset(hsrc,event,this)
%
this.createRespData;
this.refreshPanel;
% this.updateViewer;
