function setupUndo(this,hFig) 
% SETUPUNDO wire-up undo/redo menu items
%
 
% Author(s): A. Stothert 29-Apr-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/05/10 17:38:15 $

%Add an event manager to the visualization
this.EventManager = ctrluis.framemgr(hFig);
this.EventManager.EventRecorder = ctrluis.recorder;
%Add listeners to event recorder to update visualization menus
Recorder = this.EventManager.EventRecorder;
uiMgr = this.Application.getGUI;
Undo = uiMgr.findchild('Base/Menus/Edit/grpUndoRedo/Undo');
if ishandle(Undo)
   set(Undo.WidgetHandle,'UserData',...
      handle.listener(Recorder,findprop(Recorder,'Undo'),...
      'PropertyPostSet',{@LocalDoMenu Undo this}));
end
Redo = uiMgr.findchild('Base/Menus/Edit/grpUndoRedo/Redo');
if ishandle(Redo)
   set(Redo.WidgetHandle,'UserData',...
      handle.listener(Recorder,findprop(Recorder,'Redo'),...
      'PropertyPostSet',{@LocalDoMenu Redo this}));
end
end

function LocalDoMenu(hProp,event,hMenu,this) %#ok<INUSD>
%Helper function to manage state of undo/redo menus

% Update menu state and label
Stack = event.NewValue;
if isempty(Stack)
   % Empty stack
   set(hMenu.WidgetHandle,'Enable','off','Label',sprintf('&%s',get(hProp,'Name')))
else
   % Get last transaction's name
   ActionName = Stack(end).Name;
   Label = sprintf('&%s %s',get(hProp,'Name'),ActionName);
   set(hMenu.WidgetHandle,'Enable','on','Label',Label)
end
end