function updateListView
%  updateListView
%
%  This is a static method of the DAStudio.DiagViewer class.
%  Each of the show property toggle items on the DV's View menu invokes
%  this callback to show or hide the corresponding property in the DV's
%  message list view.
%
%  This method  determines what properties to include in the list view 
%  by examining the state of the corresponding toggle item on the View
%  menu. If the item is on, the corresponding property is included in
%  the list view.
%
%  Copyright 2008 The MathWorks, Inc.

  dv = DAStudio.DiagViewer.findActiveInstance();
  
  lp = {};
  
  % Construct the list of properties to display in the list view.
  % Ensure that the constructed list preserves the current property 
  % order.
  for i = 1:length(dv.msgListPropsOrder)
    propName =  dv.msgListPropsOrder{i};
    action = dv.getPropShowAction(propName);
    if strcmp(action.On, 'on'), lp = [lp propName]; end;  %#ok<AGROW>
  end
    
  % At least one property column must always appear in the list view, 
  % a limitation dictated by the Explorer infrastructure. So if there
  % is only one column visible, disable its show menu item so that the
  % user cannot hide it. Note that the Explorer does not show a context
  % menu on the first column. Thus, a user can never clear all the columns,
  % using the context menu.
  if length(lp) == 1
    action = dv.getPropShowAction(lp{1});
    action.Enable = 'off';
  else
    for i = 1:length(lp)
      action = dv.getPropShowAction(lp{i});
      action.Enable = 'on';
    end
  end
  
  dv.msgListProps = lp;
  
  lp = ['-Name' lp];
  
  dv.Explorer.setListProperties(lp);
 
  % Need to reenable list sorting after hiding or showing a column.
  imme = DAStudio.imExplorer(dv.Explorer);
  imme.enableListSorting(true, 'xyz', true);

 
end

