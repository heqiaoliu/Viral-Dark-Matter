function msg = getSelectedMsg(h)
%  GETSELECTEDMSG
%
%  Get the message currently selected in 
%  the Diagnostic Viewer's window.
%
%  Copyright 1990-2008 The MathWorks, Inc.


   ie = DAStudio.imExplorer(h.Explorer);

   msgs = ie.getSelectedListNodes;

   if ~isempty(msgs)
     msg = msgs(1); %% ME allows multiple selection.
   else
     msg = [];
   end
   
end