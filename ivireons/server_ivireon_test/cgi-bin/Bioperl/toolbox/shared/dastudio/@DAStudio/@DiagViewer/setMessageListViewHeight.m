function setMessageListViewHeight(h, height)
%  setMessageListViewHeight
%
%  Sets the height of the message list view in pixels.
%
%  Copyright 2008 The MathWorks, Inc.
  
  if isa(h.Explorer, 'DAStudio.Explorer')
    imme = DAStudio.imExplorer(h.Explorer);
    imme.setListViewWidth(height);
  else
    ME = MException('DiagnosticViewer:NoWindow', ...
      'Diagnostic viewer window does not exist.');
    throw(ME);
  end
  
end