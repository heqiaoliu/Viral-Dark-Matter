function text = getMessageListViewText(h)
%  getMessageListViewHeight
%
%  Returns the textual content of the dv's message list view as
%  a nmsgs x ncols string array.
%
%
%  Copyright 2008 The MathWorks, Inc.
  
  if isa(h.Explorer, 'DAStudio.Explorer')
    imme = DAStudio.imExplorer(h.Explorer);
    text = imme.getListViewText();
  else
    ME = MException('DiagnosticViewer:NoWindow', ...
      'Diagnostic viewer window does not exist.');
    throw(ME);
  end
  
end