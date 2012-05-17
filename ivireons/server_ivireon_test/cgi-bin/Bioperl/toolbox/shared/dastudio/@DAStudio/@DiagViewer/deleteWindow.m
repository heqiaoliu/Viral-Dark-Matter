function deleteWindow(h)
%  deleteWindow
%
%  Closes and deletes the DV's window. Note this method is intended
%  to be invoked by tests that open and close the DV programmatically.
%  It should not be invoked in contexts where a user needs to interact
%  with the DV.
%
%  Copyright 2008 The MathWorks, Inc.

    if isa(h.Explorer, 'DAStudio.Explorer')
      

        % Disconnect messages so they won't be
        % deleted by the Explorer.
        root = h.Explorer.getRoot();
        msgs = root.children;
     
        if ~isempty(msgs)
            for i = 1:length(msgs)
                 msgs(i).disconnect;
            end
        end

        h.Explorer.delete;
    end
    
    % The DV's window delete listener restores the DV to its
    % initial state after its window is deleted (see
    % installWindowDeleteListener.m.

end