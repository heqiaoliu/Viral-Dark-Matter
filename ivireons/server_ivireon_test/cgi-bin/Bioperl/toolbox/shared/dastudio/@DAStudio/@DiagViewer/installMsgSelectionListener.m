function installMsgSelectionListener(h)
%  installMsgSelectionListener
%  Installs listener for message selection changes in the 
%  Diagnostic Viewer window.

%  Copyright 2008 The MathWorks, Inc.
  

h.MsgSelectionListener = handle.listener(h.Explorer, ... 
  'MEListSelectionChanged', {@selectionChangeHandler, h});

end

function selectionChangeHandler(hExplorer, event, viewer)

  if ~isempty(event.EventData)
    msg = event.EventData(1);

    viewer.selectedMsg = msg;

    viewer.isMessageOpen = false;

    % Remove highlights from previously highlighted objects
    viewer.dehilitBlocks();

    % Highlight blocks associated with newly selected message.
    if (~isempty(msg.AssocObjectNames))
      viewer.hiliteBlocks(msg.AssocObjectHandles);
    end;

    % Reenable sorting of list view columns, i.e., allow the user to sort
    % the messages by clicking the list view column headers.
    % Note: the updateWindow method disables list sorting when it loads
    % a batch of messages into the DV. This is done to ensure that the
    % messages initially appear grouped according to type and importance.
    % Sorting is reenabled in the post selection listener to ensure that
    % loading of the messages has completed, i.e., to avoid premature
    % reenabling of sorting, which would cause the Explorer to sort them
    % alphabetically.
    imme = DAStudio.imExplorer(hExplorer);
    imme.enableListSorting(true, 'xyz', true);

  end
  
  % Lift diagnostic viewer to the top of the user's window stack.
  %
  % Fix for g500134: automated tests can open and close the DV before
  % this listener has a chance to execute. So, check to ensure that the
  % DV is supposed to be visible before bringing it to the front.
  if viewer.Visible
    viewer.toFront;
  end
  
end
