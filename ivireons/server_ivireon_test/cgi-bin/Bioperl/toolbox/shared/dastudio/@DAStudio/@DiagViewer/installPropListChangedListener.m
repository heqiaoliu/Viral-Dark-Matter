function installPropListChangedListener(h)
%  installPropListChangedListener
%  Installs a listener for changes in the number or order of properties
%  listed in the Diagnostic Viewer window (i.e., Explorer). The changes
%  result from the user either hiding a column in the list view or
%  dragging a column to a new location.

%  Copyright 2008 The MathWorks, Inc.
  

h.hPropListChangedListener = handle.listener(h.Explorer, 'MEPropListChanged', ...
  {@propListChangedHandler, h});

end

function propListChangedHandler(hExplorer, event, viewer)

  if ~isempty(event.EventData)
    newProps = event.EventData;
    
    % If the new property list is the same size as the old list,
    % the user has merely reordered the list by dragging and 
    % dropping a column in the message list view. Otherwise, the user
    % has hidden a column, using the Hide item on the column header's
    % context menu.
    if length(newProps) == length(viewer.msgListProps)
      lp = {'-Name'}; % suppresses the default Name column.
      lp = [lp; newProps];
      
      % This is needed to update the Explorer's property "override"
      % list.
      hExplorer.setListProperties(lp);
      
        
      % Need to reenable list sorting after hiding or showing a column.
      imme = DAStudio.imExplorer(hExplorer);
      imme.enableListSorting(true, 'xyz', true);
      
      % The new property list may be shorter than the DV's override list
      % because some properties may be hidden. The following code
      % updates the DV's list, maintaining the position of hidden 
      % properties, i.e., if the Source property is hidden and is second
      % in the list, it remains second in the list.
      j = 1;
      for i = 1:length(viewer.msgListPropsOrder)
        currProp = viewer.msgListPropsOrder(i);
        if ismember(currProp, newProps)
          if j <= length(newProps)
            viewer.msgListPropsOrder(i) = newProps(j);
            j = j + 1;
          end
        end
      end
      
    else
      % The user wants to hide a property. Thus, the new prop list is 
      % one item shorter than the old list.
      hideProp = char(setdiff(viewer.msgListProps, newProps));
      
      % The column corresponding to the property is not yet hidden; so
      % hide it.
      action = viewer.getPropShowAction(hideProp);
      action.On = 'off';      
    end
    
    viewer.msgListProps = newProps;
    
  end
  
end
