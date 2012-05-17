function setColumnWidths(h)
% setColumnWidths
%
% Sets the initial widths of the columns in the Diagnostic Viewer's 
% list view.
%
% Copyright 2008 The MathWorks, Inc.

  wMessage = 'Message';
  wSource = 'Source';
  wReportedBy = 'Reported By';
  wSummary = 'Summary';
  
  for i = 1:length(h.Messages)
    if length(h.Messages(i).DispType) > length(wMessage)
      wMessage = h.Messages(i).DispType;
    end
    
    if length(h.Messages(i).SourceName) > length(wSource)
      wSource = h.Messages(i).SourceName;
    end
    
    if length(h.Messages(i).Component) > length(wReportedBy)
      wReportedBy = h.Messages(i).Component;
    end
    
    if length(h.Messages(i).Summary) > length(wSummary)
      wSummary = h.Messages(i).Summary;
    end
    
  end
  
  wSummary = wSummary(1:min(length(wSummary), 80));
  
  h.Explorer.setListViewStrColWidth('Message', wMessage, 1);
  h.Explorer.setListViewStrColWidth('Source', wSource, 1);
  h.Explorer.setListViewStrColWidth('Reported By', wReportedBy, 1);
  h.Explorer.setListViewStrColWidth('Summary', wSummary, 1);

  
end