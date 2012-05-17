function selectMessageListViewRow(h, rowIndex)
%  selectMessageListViewRow
%
%  Selects a row in the diagnostic viewer's message list view.
%
%
%  Copyright 2008 The MathWorks, Inc.
  
  if isa(h.Explorer, 'DAStudio.Explorer')
    imme = DAStudio.imExplorer(h.Explorer);
    vln = imme.getVisibleListNodes;
    imme.selectListViewNode(vln(rowIndex));
  else
    ME = MException('DiagnosticViewer:NoWindow', ...
      'Diagnostic viewer window does not exist.');
    throw(ME);
  end
  
end