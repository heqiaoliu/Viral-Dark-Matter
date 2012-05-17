function enableContextMenuItems(this,EventSrc)
%ENABLECONTEXTMENUITEMS Set Context menu items appropriately

%   Authors: A. Stothert
%   Copyright 2006-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2010/03/26 17:50:08 $

%Make sure constraint is selected
if strcmp(this.Selected,'off')
   this.Selected = 'on';
end

%Determine which context menus we're allowed to show. Any menu that we
%would make visible has it's visibility set to its allowable value.
AllowMenu = localGetAllowableMenus(this);

%Get useful indices
hGroup    = this.Elements;
hChildren = hGroup.Children;
Tags      = get(hChildren,'Tag');
idxPatch  = strcmp(Tags,'ConstraintPatch');
idxEdge   = strcmp(Tags,'ConstraintInfeasibleEdge');
idxMarker = strcmp(Tags,'ConstraintMarkers');

%Set menu items common to patch and edge selection
VisibleSplit  = 'off';
VisibleFlip   = 'off';
VisibleEdit   = AllowMenu.edit;
VisibleLeft   = 'off';
CheckedLeft   = 'off';
VisibleRight  = 'off';
CheckedRight  = 'off';
VisibleExtend = 'off';
CheckedExtend = 'off';
   
%Set menu items different for patch and edge selection
if any(EventSrc == hChildren(idxEdge)) || ...
      any(EventSrc == hChildren(idxMarker))
   VisibleDelete = 'off';
   VisibleBreak  = 'off';
   idx           = idxEdge;
elseif any(EventSrc == hChildren(idxPatch))
   VisibleDelete = AllowMenu.delete;
   VisibleBreak  = AllowMenu.break;
   idx           = idxPatch;
   this.SelectedEdge = 1:size(this.xCoords,1);
end

%Find the patch/edge and its context menu
hElement   = hChildren(idx);
hMenu      = get(hElement(1),'UIContextMenu');
hMenuItems = get(hMenu,'Children');
menuTags   = get(hMenuItems,'Tag');

%Add context menu to break requirement if one doesn't exist
if ~any(strcmpi(menuTags,'break'))
   uimenu(hMenu, ...
      'Label', sprintf('Break'), ...
      'Callback', @(hSrc,hData) localBreak(this), ...
      'visible', VisibleBreak,...
      'Tag','break');
end

%Set the delete menu item correctly
idx = strcmp(menuTags, 'delete');
set(hMenuItems(idx),'Visible',VisibleDelete);

%Set the join menu items correctly
idx = strcmp(menuTags, 'left');
set(hMenuItems(idx),'Visible',VisibleLeft);
set(hMenuItems(idx),'Checked',CheckedLeft);
idx = strcmp(menuTags, 'right');
set(hMenuItems(idx),'Visible',VisibleRight);
set(hMenuItems(idx),'Checked',CheckedRight);

%Set the extend menu item correctly
idx = strcmp(menuTags, 'extend');
set(hMenuItems(idx), 'Visible', VisibleExtend);
set(hMenuItems(idx), 'Checked', CheckedExtend);

%Make the split and flip menu options visible
idx = strcmp(menuTags,'flip');
set(hMenuItems(idx),'visible',VisibleFlip);
idx = strcmp(menuTags,'split');
set(hMenuItems(idx),'visible',VisibleSplit);
idx = strcmp(menuTags,'edit');
set(hMenuItems(idx),'visible',VisibleEdit);
end

function localBreak(this)

%Extract constraint data
xCoords = this.getData('xCoords');
yCoords = this.getData('yCoords');
Weight  = this.getData('Weight');
Linked  = this.getData('Linked');
OpenEnd = this.getData('OpenEnd');
posStep = yCoords(1,1) > yCoords(3,1);

%Add new independent upper and lower bounds to represent the step
%requirement to the view
hGroup = this.Elements;
Axes = handle(hGroup.Parent);
Viewer = get(Axes.Parent,'userdata');
isViewer = isa(Viewer,'viewgui.SisoToolViewer');
if isViewer
   Plots = Viewer.getCurrentViews;
   ct = 1; found = false;
   while ct <= numel(Plots) && ~found
      PlotAxes = Plots(ct).getaxes;
      idx = PlotAxes == Axes;
      if any(idx)
         found = true;
      else
         ct = ct + 1;
      end
   end
   if found
      Plots = Plots(ct);
      upperReq = Plots.newconstr('UpperTimeResponse');
      lowerReq = Plots.newconstr('LowerTimeResponse');
   else
      %Error finding view, return without splitting
      return
   end 
else
   %Add requirement to axes directly
   upperReq = plotconstr.timeresponse(...
      'Parent', hGroup.Parent, ...
      'PatchColor',this.PatchColor);
   upperReq.setDisplayUnits('XUnits',this.getDisplayUnits('XUnits'));
   upperReq.setDisplayUnits('YUnits',this.getDisplayUnits('YUnits'));
   upperReq.Type = 'upper';
   lowerReq = plotconstr.timeresponse(...
      'Parent', hGroup.Parent, ...
      'PatchColor',this.PatchColor);
   lowerReq.setDisplayUnits('XUnits',this.getDisplayUnits('XUnits'));
   lowerReq.setDisplayUnits('YUnits',this.getDisplayUnits('YUnits'));
   lowerReq.Type = 'lower';
end

%Set data for upper and lower pieces
if posStep
   upperReq.Requirement.setData(...
       'xData', xCoords(1:2,:), ...
       'yData', yCoords(1:2,:), ...
       'Weight', Weight(1:2,:), ...
       'Linked', Linked(1,:), ...
       'OpenEnd', OpenEnd);
   lowerReq.Requirement.setData(...
       'xData', xCoords(3:5,:), ...
       'yData', yCoords(3:5,:), ...
       'Weight', Weight(3:5,:), ...
       'Linked', Linked(3:4,:), ...
       'OpenEnd', OpenEnd);
else
   upperReq.Requirement.setData(...
       'xData', xCoords(3:5,:), ...
       'yData', yCoords(3:5,:), ...
       'Weight', Weight(3:5,:), ...
       'Linked', Linked(3:4,:), ...
       'OpenEnd', OpenEnd);
   lowerReq.Requirement.setData(...
       'xData', xCoords(1:2,:), ...
       'yData', yCoords(1:2,:), ...
       'Weight', Weight(1:2,:), ...
       'Linked', Linked(1,:), ...
       'OpenEnd', OpenEnd);
end

upperReqView = upperReq.Requirement.getView(Plots);
upperReqView.PatchColor = Plots.Options.RequirementColor;
lowerReqView = lowerReq.Requirement.getView(Plots);
lowerReqView.PatchColor = Plots.Options.RequirementColor;
if isViewer
   %Add constraint to viewer plot
   Plots.addconstr(upperReqView);
   Plots.addconstr(lowerReqView);
   % Notify client listeners that new requirement added
   ed = plotconstr.constreventdata(Plots,'RequirementAdded');
   ed.Data = upperReqView;
   Plots.send('RequirementAdded',ed);
   ed = plotconstr.constreventdata(Plots,'RequirementAdded');
   ed.Data = lowerReqView;
   Plots.send('RequirementAdded',ed);
else
   %Activate new requirements
   upperReqView.initialize;
   lowerReqView.initialize;
   %Activate the new requirements
   upperReqView.Activated = true;
   lowerReqView.Activated = true;
end

%Delete the step response
delete(this.getRequirementObject)
end

function AllowableMenus = localGetAllowableMenus(this)
%Helper function to determine which menus we should not show under any
%circumstance

%By default assume all menus are allowable
AllowableMenus = struct(...
   'edit', 'on', ...
   'delete', 'on', ...
   'break', 'on');

if isstruct(this.AllowContextMenu)
   flds = fieldnames(this.AllowContextMenu);
   for ct = 1:numel(flds)
      AllowableMenus.(flds{ct})= this.AllowContextMenu.(flds{ct});
   end
end
end