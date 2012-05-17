function IsOwner = mouseevent(Editor,EventName,EventSrc)
%MOUSEEVENT  Processes mouse events.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.33.4.7 $  $Date: 2006/06/20 20:02:44 $

PlotAxes = getaxes(Editor.Axes);

IsOwner = 0;
if strcmp(EventName,'wbm')
   % Top-down handling of mouse motion. Determine if mouse is over any editor axes
   inFocus = [];
   for ct = 1:length(PlotAxes)
       CP = get(PlotAxes(ct),'CurrentPoint');
       CP = CP(1,1:2);
       Ylim = get(PlotAxes(ct),'Ylim');
       Xlim = get(PlotAxes(ct),'Xlim');
       inFocus = [inFocus; CP(1,1)>=Xlim(1) && CP(1,1)<=Xlim(2) && ...
           CP(1,2)>=Ylim(1) && CP(1,2)<=Ylim(2) && strcmp(get(PlotAxes(ct),'Visible'),'on')];
   end
   
   % Set ownership flag. Exit if no further action required
   IsOwner = any(inFocus);
   if ~IsOwner | strcmp(Editor.EditMode,'off')
      % Exit if editor does not own the event or is turned off
      return
   end
   
   % Pass event to editor's children and give right of way to any taker
   if strcmp(Editor.EditMode,'idle')
      idx = 1;
      ConstrChildren = find(PlotAxes,'-depth', 1, ...
	      '-isa', 'plotconstr.designconstr', 'Activated', 1);
      
      while idx <= numel(ConstrChildren)
         % REVISIT: should traverse from right to left to respect order of creation and HG layering
         if ishandle(ConstrChildren(idx)) && ...
               mouseevent(ConstrChildren(idx),EventName)
            return
         end
         idx = idx+1;
      end
   end
end

% Process event if no child is taker
EventMgr = Editor.EventManager;
Status = EventMgr.Status;
HostFig = EventMgr.Frame;
SelectType = get(HostFig,'SelectionType');
if Editor.SingularLoop
   % Abort if editor is crippled
   EventMgr.poststatus(sprintf('This editor is disabled due to algebraic loop.'));
   return
end
   
switch EventName
case 'bd'
   % ButtonDown event on Editor axes
   if strcmp(SelectType,'alt')
      % Right-click should behave as normal
      return
   end
   
   switch Editor.EditMode
   case 'idle'
      % Click in normal mode
      if usejava('MWT')    % Creates PropertyEditors related MouseEvents only when Java is enabled
         switch SelectType
         case 'normal'
            PropEdit = PropEditor(Editor,'current');  % handle of (unique) property editor
            if ~isempty(PropEdit) & PropEdit.isVisible
               % Left-click & property editor open: quick target change
               PropEdit.setTarget(Editor);
            end
            % Unselect all objects
            Editor.EventManager.clearselect(PlotAxes);
         case 'open'
            PropEdit = PropEditor(Editor);
            PropEdit.setTarget(Editor)      
         end
      end
   case 'addpz'
      % Initiate add pole/zero
      LocalAdd([],[],'start',Editor,handle(EventSrc));
   case 'deletepz'
      % Delete pole/zero
      if ~Editor.SingularLoop && ~isempty(Editor.EditedPZ)
         Editor.deletepz(handle(EventSrc));
      end
      Editor.EditMode = 'idle';  % resets pointer through listener
  
   end
   
case 'wbm'
   % WindowButtonMotion event
   switch Editor.EditMode
   case 'idle'
      % Hovering over editor in idle mode
      [PointerType,Status] = hoverstatus(Editor,Status);
      
   case 'addpz'
      % Dragging pole/zero
      Group = Editor.EditModeData.Group;
      if any(strcmp(Group,{'Real','Complex'}))
         PZID = lower(Editor.EditModeData.Root);  % pole or zero
         PointerType = sprintf('add%s',PZID); % addpole or addzero
         Status = sprintf('Left-click where you want to add this %s.',PZID);
      else
         PointerType = 'addpole';  % default
         Status = sprintf('Left-click where you want to add this %s.',lower(Group));
      end
      
   case 'deletepz'
      % Deleting pole/zero
      PointerType = 'eraser';
      Status = sprintf('Left-click on the pole/zero you want to delete.');
      
   otherwise
      % Default
      PointerType = 'arrow'; 
   end  
   
   % Update dynamic status and pointer
   EventMgr.poststatus(Status);
   if xor(strcmp(get(HostFig,'Pointer'),'arrow'),strcmp(PointerType,'arrow'))
      setptr(HostFig,PointerType)
   end
   
end


%----------------------- Local Functions ----------------------------

%%%%%%%%%%%%%%%%
%%% LocalAdd %%%
%%%%%%%%%%%%%%%%
function LocalAdd(hSrc,junk,action,Editor,CurrentAxes)
% Manages add pole/zero (Add takes place on button up
persistent WBMU

EventMgr = Editor.EventManager;
HostFig = EventMgr.Frame;

switch action
case 'start'
   % Initialize Add. Take over window mouse events
   WBMU = get(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
   set(HostFig,'WindowButtonMotionFcn','',...
      'WindowButtonUpFcn',{@LocalAdd 'finish' Editor CurrentAxes});
   % Update status message
   EventMgr.poststatus(sprintf('Release the mouse to add the pole/zero.'));
   
case 'finish'
   % Add ends. Restore initial conditions
   set(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU)
   % Add root and return to idle mode (single shot)
   if ~Editor.SingularLoop
      Editor.addpz(CurrentAxes);
   end
   Editor.EditMode = 'idle';  % resets pointer through listener to EditMode
end


