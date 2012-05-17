function enableContextMenuItems(Constr,EventSrc)
%ENABLECONTEXTMENUITEMS Set Context menu items appropriately

%   Authors: A. Stothert
%   Copyright 2006-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2010/03/26 17:50:06 $

%Make sure constraint is selected
if strcmp(Constr.Selected,'off')
   Constr.Selected = 'on';
end

%Determine which context menus we're allowed to show. Any menu that we
%would make visible has it's visibility set to its allowable value.
AllowMenu = localGetAllowableMenus(Constr);

%Get useful indices
hChildren = Constr.Elements.Children;
Tags      = get(hChildren,'Tag');
idxPatch  = strcmp(Tags,'ConstraintPatch');
idxEdge   = strcmp(Tags,'ConstraintInfeasibleEdge');
idxMarker = strcmp(Tags,'ConstraintMarkers');

if any(EventSrc == hChildren(idxEdge)) || ...
      any(EventSrc == hChildren(idxMarker))
   MenuType      = 'Edge';
   VisibleSplit  = AllowMenu.split;
   VisibleFlip   = 'off';
   VisibleEdit   = AllowMenu.edit;
   VisibleDelete = AllowMenu.delete;
   idx           = idxEdge;
elseif any(EventSrc == hChildren(idxPatch))
   MenuType      = 'Patch';
   VisibleSplit  = 'off';
   VisibleFlip   = AllowMenu.flip;
   VisibleEdit   = AllowMenu.edit;
   VisibleDelete = AllowMenu.delete;
   idx           = idxPatch;
   Constr.SelectedEdge = 1:size(Constr.xCoords,1);
end

%Find the patch and its context menu
hMenu      = get(hChildren(idx),'UIContextMenu');
hMenuItems = get(hMenu,'Children');
menuTags   = get(hMenuItems,'Tag');
%Check the orientation so that correct axis
%join state is displayed
switch Constr.Orientation
   case 'horizontal', idxOrient = 2;     %y-coord is free
   case 'vertical',   idxOrient = 1;     %x-coord is free
   case 'both',       idxOrient = [];    %niether coord is free
end
if ~strcmp(MenuType,'Patch') && ~isempty(idxOrient)
   switch Constr.SelectedEdge
      case 1
         %Edge at left end, doesn't have a left neighbour
         VisibleLeft = 'off';
         CheckedLeft = 'off';
         if size(Constr.xCoords,1)==1
            %Only one constraint
            VisibleRight = 'off';
            CheckedRight = 'off';
         else
            VisibleRight = AllowMenu.right;
            if Constr.Linked(1,idxOrient)
               CheckedRight = 'on';
            else
               CheckedRight = 'off';
            end
         end
      case size(Constr.xCoords,1)
         %Edge at right end, doesn't have a right neighbour
         VisibleRight = 'off';
         CheckedRight = 'off';
         if size(Constr.xCoords,1)==1
            %Only one constraint
            VisibleLeft = 'off';
            CheckedLeft = 'off';
         else
            VisibleLeft = AllowMenu.left;
            if Constr.Linked(end,idxOrient)
               CheckedLeft = 'on';
            else
               CheckedLeft = 'off';
            end
         end
      case num2cell(2:size(Constr.xCoords,1)-1)
         %Edge in the middle, has both left and right neighbour
         VisibleLeft = AllowMenu.left;
         if Constr.Linked(Constr.SelectedEdge-1,idxOrient)
            CheckedLeft = 'on';
         else
            CheckedLeft = 'off';
         end
         VisibleRight = AllowMenu.right;
         if Constr.Linked(Constr.SelectedEdge,idxOrient)
            CheckedRight = 'on';
         else
            CheckedRight = 'off';
         end
      otherwise
         %No edge selected
         VisibleLeft  = 'off';
         VisibleRight = 'off';
         CheckedLeft  = 'off';
         CheckedRight = 'off';
   end
else
   %Neither coord is free, turn off all join menus
   VisibleLeft  = 'off';
   VisibleRight = 'off';
   CheckedLeft  = 'off';
   CheckedRight = 'off';
end

%Set extend menu options
OpenEnd = Constr.Data.getData('OpenEnd');
if numel(Constr.SelectedEdge) == 1
   switch Constr.SelectedEdge
      case 1
         %Edge at left end, doesn't have a left neighbour
         VisibleExtend = AllowMenu.extend;
         if OpenEnd(1)
            CheckedExtend = 'on';
         else
            CheckedExtend = 'off';
         end
      case size(Constr.xCoords,1)
         %Edge at right end, doesn't have a right neighbour
         VisibleExtend = AllowMenu.extend;
         if OpenEnd(2)
            CheckedExtend = 'on';
         else
            CheckedExtend = 'off';
         end
      otherwise
         %No edge selected
         VisibleExtend = 'off';
         CheckedExtend = 'off';
   end
else
   %No extend edge option
   VisibleExtend = 'off';
   CheckedExtend = 'off';
end
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

%Make the edit and delete menu options visible
idx = strcmp(menuTags,'edit');
set(hMenuItems(idx),'visible',VisibleEdit);
idx = strcmp(menuTags,'delete');
set(hMenuItems(idx),'visible',VisibleDelete);
end

function AllowableMenus = localGetAllowableMenus(Constr)
%Helper function to determine which menus we should not show under any
%circumstance

%By default assume all menus are allowable
AllowableMenus = struct(...
   'edit', 'on', ...
   'delete', 'on', ...
   'split', 'on', ...
   'left', 'on', ...
   'right', 'on', ...
   'flip', 'on', ...
   'extend', 'on');

if isstruct(Constr.AllowContextMenu)
   flds = fieldnames(Constr.AllowContextMenu);
   for ct = 1:numel(flds)
      AllowableMenus.(flds{ct})= Constr.AllowContextMenu.(flds{ct});
   end
end
end
