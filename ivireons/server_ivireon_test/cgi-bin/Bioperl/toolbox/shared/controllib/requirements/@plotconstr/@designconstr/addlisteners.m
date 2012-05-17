function addlisteners(Constr,Listeners)
%ADDLISTENERS  Installs listeners for gain constraints.

%   Author(s): N. Hickey
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:52 $

if nargin == 1
   % Clear existing listeners (e.g., after clone operation)
   delete(Constr.Listeners);
   % Listeners to HG axes events and properties
   localAddAxesListeners(Constr);
   % Listeners to constraint properties
   L1 = [handle.listener(Constr, Constr.findprop('Selected'), ...
         'PropertyPostSet', @LocalSelect) ; ...
         handle.listener(Constr, Constr.findprop('Zlevel'), ...
         'PropertyPostSet', @LocalSetZlevel) ; ...
         handle.listener(Constr, Constr.findprop('EditDlg'), ...
         'PropertyPreGet', @LocalDefaultEditor) ; ...
         handle.listener(Constr, Constr.findprop('TextEditor'), ...
         'PropertyPreGet', {@LocalGetTextEditor Constr.requirementObj}) ; ...
         handle.listener(Constr, Constr.findprop('Activated'),...
         'PropertyPreSet', @LocalOnOff)  ;...
         handle.listener(Constr, Constr.findprop('Activated'),...
         'PropertyPostSet', @LocalTargetEditor)  ;...
         handle.listener(Constr, Constr.findprop('isLocked'), ...
         'PropertyPostSet', @LocalLock); ...
         handle.listener(Constr, 'ObjectBeingDestroyed',@LocalPreDelete)];
   localAddElementsListeners(Constr)
   %Listeners to data object
   L2 = [...
       handle.listener(Constr.Data,'DataChanged', @LocalDataChanged); ...
       handle.listener(Constr.Data,'ObjectBeingDestroyed', @LocalDataDeleted)];
   Constr.Listeners = [L1;L2];
   set(Constr.Listeners,'CallbackTarget',Constr)
else
   % Add to list of listeners
   Constr.Listeners = [Constr.Listeners; Listeners];    
end


%-------------------------Property listeners-------------------------

function localAddAxesListeners(Constr)
%Local function to add axes listeners. 
%
%Used by anonymous fcn call and prevents workspace being saved by anonymous
%function

PlotAxes = handle(Constr.Elements.Parent);
addlistener(PlotAxes,'ObjectBeingDestroyed', @(hSrc,hData) LocalCleanUp(Constr));
addlistener(PlotAxes,'Visible','PostSet', @(hSrc,hData) LocalToggleVisible(Constr,PlotAxes));

function localAddElementsListeners(Constr)
%Local function to add Constraint listeners. 
%
%Used by anonymous fcn call and prevents workspace being saved by anonymous
%function
addlistener(Constr.Elements, 'ObjectBeingDestroyed', @(hSrc,hData) LocalCleanUp(Constr));


%%%%%%%%%%%%%%%%%%%%
%  LocalPreDelete  %
%%%%%%%%%%%%%%%%%%%%
function LocalPreDelete(Constr,~,~)
% Pre-delete actions
% Always deselect before deleting (ensures undo will add it back to list of selected objects)
Constr.Selected = 'off';
% Delete children
hGroup = Constr.Elements;
if ishghandle(hGroup)
   %Make sure we delete the context menu
   cMenu = Constr.Handles.cMenu;
   cMenu = cMenu(ishghandle(cMenu));
   delete(cMenu)
   %Delete the group children
   hChildren = hGroup.Children;
   delete(hGroup.Children(ishghandle(hChildren)))
   delete(hGroup)
end

%%%%%%%%%%%%%%%%%
%  LocalOnOff   %
%%%%%%%%%%%%%%%%%
function LocalOnOff(Constr,eventData)
% Toggles Activated state (preset callback)
%disp(sprintf('preset for Activated = %d',eventData.NewValue))
if eventData.NewValue,  
   % Going to active mode: render constraint and notify observers (needed for redo)
   render(Constr);
end


%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalTargetEditor   %
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalTargetEditor(Constr,eventData)
% PostSet for Activated=0/1
if Constr.EditDlg.isVisible
    if eventData.NewValue
        % Constraint editor is up, retarget it to activated constraint
        Constr.EditDlg.target(Constr.TextEditor);
    else
        % De-target constraint editor
        Constr.EditDlg.detarget(Constr.TextEditor);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalGetTextEditor  %
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalGetTextEditor(Constr,~,reqObj)
if isempty(Constr.TextEditor)
    Constr.TextEditor = reqObj.getEditor(Constr.EditDlg,'AutoShow',false,'View',Constr);
    Constr.TextEditor.HelpData     = Constr.HelpData;
    Constr.TextEditor.EventManager = Constr.EventManager;
    Constr.TextEditor.setDisplayUnits('xunits',Constr.getDisplayUnits('xUnits'))
    Constr.TextEditor.setDisplayUnits('yunits',Constr.getDisplayUnits('yUnits'))
end


%%%%%%%%%%%%%%%%%%
%  LocalSelect   %
%%%%%%%%%%%%%%%%%%
function LocalSelect(Constr,~)
% Sets Selected property of line objects and plots end markers
EventMgr = Constr.EventManager;
hGroup = Constr.Elements;
if ~ishghandle(hGroup,'hggroup')
   disp('No group on select...')
   return
end
HostAx = handle(hGroup.Parent);
HostFig = HostAx.Parent;

if strcmp(Constr.Selected, 'on')
   % Object becomes selected
   % Add to axes list of selected objects
   if strcmp(get(HostFig,'SelectionType'), 'extend')
      % Multi-select
      EventMgr.addselect(Constr,handle(hGroup.Parent));
   else
      % Single-select
      EventMgr.newselect(Constr,handle(hGroup.Parent));
   end
   % Turn markers on
    Constr.setMarkersOn('on');
else
   EventMgr.rmselect(Constr);
    % Turn markers off
    Constr.setMarkersOn('off');
end    


%%%%%%%%%%%%%%%%%%
% LocalCleanUp   %
%%%%%%%%%%%%%%%%%%
function LocalCleanUp(Constr)
% Clean up when @axes deleted (needed because persistent editor may contain reference
% that will prevent deletion)
if ishandle(Constr)
   %Force deletion of whole constraint
   Constr.Selected = 'off';
end
delete(Constr(ishandle(Constr)));

%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalToggleVisible    %
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalToggleVisible(Constr,PlotAxes)
% Toggle visibility
if isempty(Constr) || ~ishandle(Constr)
    %Quick return, invalid constraint
    return
end
if ishghandle(Constr.Elements)
   set(Constr.Elements,'Visible',get(PlotAxes,'Visible'))
end

%%%%%%%%%%%%%%%%%%%%%
% LocalSetZlevel    %
%%%%%%%%%%%%%%%%%%%%%
function LocalSetZlevel(Constr,eventData)
% Sets Selected property of line objects and plots end markers
hGroup = Constr.Elements;
hgobj  = hGroup.Children;
for h=hgobj(:)'
   if strcmp(get(h,'Type'),'patch')
      % Do not use Zdata when patch specified in terms of Vertices
      vdata  = get(h,'Vertices');
      vdata(:,3) = eventData.NewValue;
      set(h,'Vertices',vdata)
   else
      if isprop(h,'zdata')
         zdata = get(h,'Zdata');
         zdata(:) = eventData.NewValue;
         set(h,'Zdata',zdata);
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalDefaultEditor   %
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDefaultEditor(Constr,~)
% PreGet listener on TextEditor property
% if ~isa(Constr.TextEditor,'plotconstr.constreditor')
%    % Set to default editor
%    Constr.TextEditor = plotconstr.editdlg;
% end
if ~isa(Constr.EditDlg,'editconstr.editdlg') && ~isa(Constr.EditDlg,'plotconstr.constreditor')
   % Set to default editor
    Constr.EditDlg = editconstr.editdlg;
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDataChanged      %
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDataChanged(Constr,~)
% Update constraint
Constr.update

%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDataDeleted      %
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDataDeleted(Constr,~)
% Update constraint
delete(Constr)

%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalLock              %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalLock(Constr,~)
%Set constraint context menu based on locked status

if ~isempty(Constr.Elements)
   %Change the constraint context menu depending on the locked state. When
   %unlocked we want to use the context menus of the constraint but when
   %locked use the context menu of the parent axis.
   hChildren = Constr.Elements.Children;
   allTags = get(hChildren,'Tag');
   idx = strcmp(allTags,'ConstraintPatch');
   idx = idx | strcmp(allTags,'ConstraintInfeasibleEdge');
   hChildren = hChildren(idx);
   if Constr.isLocked
      hAx = Constr.Elements.Parent;
      set(hChildren,'UIContextMenu',get(hAx,'UIContextMenu'));
   else
      set(hChildren,'UIContextMenu',Constr.Handles.cMenu)
   end
end


