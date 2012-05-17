function installVisibleListener(h)
% installVisibleListener
%   
% Installs a listener for changes to the Diagnostic Viewer's Visible
% property. The listener shows or hides the Diagnostic Viewer, depending
% on whether the Visible property is true or false, respectively.
%
%  Copyright 2008 The MathWorks, Inc.

  
hVisib = findprop(h, 'Visible');
h.hVisListener = handle.listener(h, hVisib, ...
                         'PropertyPostSet', {@visible_listener,h});
end

function visible_listener(obj, evd, h) %#ok<INUSL>

  % Suppress warnings that can occur when attempting to
  % highlight blocks as part of making DV visible or removing
  % highlights when hiding DV.
  % Fix for g216390.
  wState = warning;
  warning off; %#ok<WNOFF> 
  
  % Create instance of the Model Explorer. The DV uses the Explorer 
  % instance to display error messages.
  if isempty(h.Explorer) && h.Visible
    h.createExplorer;
    h.Explorer.show();
    return;
  else    
    if isa(h.Explorer, 'DAStudio.Explorer')
      if h.Visible
        h.updateWindow;
        h.Explorer.show();
      else
        % Temporary to keep tests that bring up the
        % dv from failing. 
        % h.Explorer.hide();
        h.deleteWindow();
        dehilitBlocks(h);
        dehilitModelAncestors(h);
      end     
    end
  end
     
  warning(wState);
   
end
