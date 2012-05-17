function refresh(h)
%REFRESH  Updates popup.

%   Authors: P. Gahinet
%   Revised: A. Stothert, switch to MJcomponents
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:05 $

% RE: Assumes container/constraint list is non empty

% Update constraint list
List = h.ConstraintList;
List = List(isvalid(List));
if ~isempty(List)
    LocalConstraintsPopUp(h, List, find(h.Constraint==List));
end
end

%% Repopulate and set constraints combobox
function LocalConstraintsPopUp(h, List, index)
% Clean-up the choice list
PopUp       = h.Handles.TypeSelect;
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
    PopUp.repaint;
end
end