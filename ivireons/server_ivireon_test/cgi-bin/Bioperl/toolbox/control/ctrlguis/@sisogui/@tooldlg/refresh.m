function refresh(h,key)
%REFRESH  Updates popup lists.

%   Authors: P. Gahinet
%   Revised: A. Stothert, switch to MJcomponents
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $ $Date: 2006/05/27 18:03:07 $

% RE: Assumes container/constraint list is non empty

switch key
case 'Containers'
    % Update container list
    List = h.getlist('ActiveContainers');
    LocalContainerPopUp(h, List, find(h.Container==List));
    
case 'Constraints'
    % Update constraint list
    List = h.ConstraintList;
    LocalConstraintsPopUp(h, List, find(h.Constraint==List));    
end 


%% Repopulate and set container combobox
function LocalContainerPopUp(h, List, index)
% Clean-up the Choice list
PopUp = h.Handles.EditorSelect;
awtinvoke(PopUp,'removeAllItems');

% Update choice list content
for ct = 1:length(List)
  % Remove '(C)' and '(F)' from the title strings
  str = List(ct).Axes.Title;
  str = strrep(strrep(str, '(C)', ''), '(F)','');
  awtinvoke(PopUp,'addItem(Ljava/lang/Object;)',sprintf(str));
end
if numel(List)>0 && ~isempty(index)
   awtinvoke(PopUp,'setSelectedIndex(I)',index-1); % Choice index begin from zero, vector index from one
end
PopUp.repaint;

%% Repopulate and set constraints combobox
function LocalConstraintsPopUp(h, List, index)
% Clean-up the choice list
PopUp       = h.Handles.ConstrSelect;
nPopUpItems = PopUp.getItemCount;
nList       = numel(List);

%Determine if the popup needs to be refreshed
refreshPopUp = nList ~= nPopUpItems; %Change in number of items
if ~refreshPopUp
   %Check if any items changed
   ct = 1;
   while ~refreshPopUp && ct <= nPopUpItems
      if strcmp(PopUp.getItemAt(ct-1),List(ct).describe('detail'))
         ct = ct + 1;
      else
         refreshPopUp = true;
      end
   end
end

if refreshPopUp
   % Update choice list content
   awtinvoke(PopUp,'removeAllItems');
   for ct = 1:length(List)
      awtinvoke(PopUp,'addItem(Ljava/lang/Object;)',sprintf(List(ct).describe('detail')));
   end
end

%Switch to selected item
if ~isempty(index)
   awtinvoke(PopUp,'setSelectedIndex(I)',index-1); % Choice index begin from zero, vector index from one
end
PopUp.repaint;