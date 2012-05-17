function updateWindow(h)
%  updateWindow
%
%  Update the set of messages displayed in the message explorer.
% 
%  Copyright 2008 The MathWorks, Inc.
   
    
   if isa(h.Explorer, 'DAStudio.Explorer')
     
     imme = DAStudio.imExplorer(h.Explorer);
      
     % If Explorer is visible, put it to sleep until we are done updating 
     % its message tree. We can then weke it up, thereby forcing it to
     % refresh itself to reflect its new contents.
     if h.Explorer.isVisible       
       h.sleepExplorer();
     end
     
     % Disable the Explorer's message sorting mechanism so that it displays
     % the messages in the same order as they are listed in the DV itself,
     % i.e., all error messages first, then all warnings, then everything
     % else. We will reenable sorting after the Explorer becomes visible
     % so that the user can sort the messages by clicking the list view
     % column headers.
     imme.enableListSorting(false, 'xyz', true);

     % Get the root of the message tree, which is an object of
     % DAStudio.DiagMessageContainer class.
     root = h.Explorer.getRoot;    
         
     % Disconnect but do not delete any existing messages in the
     % message container. Do not delete the existing messages because
     % the update may simply be to display messages added to those 
     % already being displayed in an open viewer.
     msgs = root.children;
     
     if ~isempty(msgs)
       for i = 1:length(msgs)
         msgs(i).disconnect;
       end
     end
   
  
     % Connect new messages to the message container.
     msgs = h.messages;
     
     if isempty(msgs)
       msgs = h.NullMessage;
       msgs(1).connect(root, 'up');
     else
       for i = 1:length(msgs)
         msgs(i).connect(root, 'up');      
       end
     end
     
     % Add messages  to the window
     root.children = msgs;
     
     % Size the list view column widths to be wide enough to accommodate
     % the widest text that appears in the columns.
     h.setColumnWidths();
     
          
     % Time for the Explorer to wake up and refresh itself to reflect
     % its new contents.
     if imme.isVisible
       h.wakeExplorer();
     end
     
     % Initialize to reflect new batch of messages.
     h.selectedMsg = [];
     
     % If Explorer is visible, e.g., because it remains open after
     % a previous model was simulated, select first message. Note that
     % the Explorer post show listener (see 
     % installWindowPostShowListener.m) handles selection in the case 
     % where the Explorer is updated while it is hidden and then is shown.
     % 
     % Note: that h.Visible is not a reliable indication that the Explorer
     % window is visible because this method can be called before the
     % Explorer is made visible as well as while it is visible.
     if imme.isVisible
       if isempty(h.Messages)
         if h.getSelectedMsg() == h.NullMessage
            h.selectedMsg = h.NullMessage;
         else
            h.selectDiagnosticMsg(h.NullMessage);
         end
       else
         h.selectDiagnosticMsg(h.Messages(1));
       end
       h.toFront;
     end
          
   end
   
end
