function addlisteners(Editor)
%ADDLISTENERS  Installs generic listeners for graphical editors.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.29.4.4 $ $Date: 2009/04/21 03:08:13 $
LoopData = Editor.LoopData;

% Targeted and event listeners
% RE: ViewChanged: needed for changes in limit modes/props
L = [handle.listener(Editor,findprop(Editor,'Visible'),...
      'PropertyPostSet',@LocalMakeVisible) ; ...
      handle.listener(Editor,findprop(Editor,'LabelColor'),...
      'PropertyPostSet',@setlabelcolor); ...
      handle.listener(Editor,findprop(Editor,'LineStyle'),...
      'PropertyPostSet',@update); ...
      handle.listener(Editor,findprop(Editor,'EditMode'),...
      'PropertyPostSet',@LocalModeChanged); ...
      handle.listener(Editor,findprop(Editor,'RefreshMode'),...
      'PropertyPostSet',@hgset_refresh);...
      handle.listener(Editor,findprop(Editor,'SingularLoop'),...
      'PropertyPostSet',@LocalSingularLoop);...
      handle.listener(LoopData,'LoopDataChanged',@LocalDataChanged) ; ...
      handle.listener(LoopData,'FirstImport',@activate) ; ...
      handle.listener(LoopData,'MoveGain',@LocalMoveGain) ; ...
      handle.listener(LoopData,'MovePZ',@LocalMovePZ);...
      handle.listener(LoopData,'ConfigChanged',@configure);...
      handle.listener(Editor,'ObjectBeingDestroyed',@LocalCleanUp) ];
set(L,'CallbackTarget',Editor)
Editor.Listeners = L;    


%-------------------------Property listeners-------------------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalMakeVisible %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMakeVisible(Editor,event)
% PostSet callback for Visible property
sisodb = Editor.up;

% Make axes visible
% RE: Must be done first to properly set label visibility (used by layout)
hgset_visible(Editor);

% Update host's layout 
% RE: This must be done before UPDATE so that axes dimensions are correct 
%     (influences tick picker and phase ticks, cf. sisotool(1)+view filter)
if ~isempty(sisodb)
   layout(sisodb);
end

% Update editor's contents
if strcmp(Editor.Visible,'on')
   % Update title and get list of tuned models this editor depends on
   % RE: Always do this because of retargeting
   configure(Editor)
   
   % Update editor contents
   if strcmp(Editor.EditMode,'off')
      % REVISIT: Hack to geck rid unit circle, waiting for push/pop stack
      updateview(Editor)
   else
      update(Editor)
   end
end


%%%%%%%%%%%%%%%%%%%%
%%% LocalCleanUp %%%
%%%%%%%%%%%%%%%%%%%%
function LocalCleanUp(Editor,eventData)
% Clean up when editor is deleted
delete(Editor.Axes);


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDataChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDataChanged(Editor,event)
% Callback for 'LoopDataChanged' event
EventData = Editor.LoopData.EventData;
C = EventData.Component;
if strcmp(EventData.Scope,'all')
   % Global update
   Editor.update;
elseif any(C==Editor.Dependency)
   % Editor depends on the modified component
   if Editor.EditedBlock==C && strcmp(EventData.Scope,'gain')
      % Gain of edited model was changed
      Editor.updategain;
   else
      % Full update
      Editor.update;
   end
end
  

%%%%%%%%%%%%%%%%%%%%%
%%% LocalMoveGain %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalMoveGain(Editor,event)
% Notifies editors of MOVEGAIN start and finish events
if Editor.Enabled && strcmp(Editor.Visible,'on') && ~Editor.SingularLoop
   EventData = Editor.LoopData.EventData;
   C = EventData.Component;  % tuned model being modified
   if any(C==Editor.LoopData.L(Editor.EditedLoop).TunedFactors)
      % Fast update when modifiying gain of edited model
      Editor.refreshgain(EventData.Phase)  % init or finish
   elseif any(C==Editor.Dependency)
      Editor.refresh(EventData.Phase,C)
   end
end
    

%%%%%%%%%%%%%%%%%%%
%%% LocalMovePZ %%%
%%%%%%%%%%%%%%%%%%%
function LocalMovePZ(Editor,event)
% Notifies editors of MOVEPZ:init and MOVEPZ:finish events
if Editor.Enabled && strcmp(Editor.Visible,'on') && ~Editor.SingularLoop
   EventData = Editor.LoopData.EventData;
   C = EventData.Component;  % tuned model being modified
   if any(C==Editor.LoopData.L(Editor.EditedLoop).TunedFactors)
      % Fast update when modifiying pz of edited model
      Editor.refreshpz(EventData.Phase,EventData.Extra)  
   elseif any(C==Editor.Dependency)
      Editor.refresh(EventData.Phase,C,EventData.Extra)
   end
   % RE: Phase = init or finish, Extra = handle of moved PZ group
end
   

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalModeChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalModeChanged(Editor,event)
% Callback when switching edit mode
if strcmp(Editor.EditMode,'idle')
	% Returning to idle (for safety...)
	Editor.RefreshMode = 'normal';
	% Reset figure pointer
	set(Editor.EventManager.Frame,'Pointer','arrow');
else
    % Clear selected objects within Editor scope
    Editor.EventManager.clearselect(getaxes(Editor.Axes));
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSingularLoop %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSingularLoop(Editor,event)
% Callback when SingularLoop changes
if Editor.SingularLoop
   Editor.setmenu('off')
else
   Editor.setmenu('on')
end