function addEditorListeners(this,varargin)
% Adds or reinstalls listeners to graphical editor properties

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:43:56 $
HG = this.HG;
PlotEditors = this.PlotEditors;

% Remove current listeners
delete(this.EditorListeners)

% Install listeners
Listeners = handle.listener(PlotEditors,PlotEditors(1).findprop('EditMode'),...
        'PropertyPostSet',@LocalModeChanged);

% Target listener callbacks
set(Listeners,'CallbackTarget',this)

% Make listeners persistent
this.EditorListeners = Listeners;

%----------------- Local Functions -----------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalModeChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalModeChanged(sisodb,event)
% Called when EditMode changes in some Editor
if strcmp(event.NewValue,'idle')
    % Abort any global mode when some editor returns to idle (local mode change)
    sisodb.GlobalMode = 'off';
end


