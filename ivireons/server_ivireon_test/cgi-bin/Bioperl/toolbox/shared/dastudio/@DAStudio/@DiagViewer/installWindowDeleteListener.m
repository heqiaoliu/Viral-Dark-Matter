function installWindowDeleteListener(h)
% installWindowDeleteListener
%   
% Installs a listener for an attempt to delete the Diagnostic Viewer's
% window, i.e., Explorer instance. This occurs during testing when the
% testing harness deletes all Explorer instance after a test point as
% part of test point cleanup. This delete listener sets the viewer's 
% Explorer instance property to null and its Visible property to false. 
% This will trigger creation of another Explorer instance the next time
% the nag controller tries to display the viewer.
%
%  Copyright 2008 The MathWorks, Inc.

h.WindowDeleteListener = handle.listener(h.Explorer, ...
  'ObjectBeingDestroyed', {@window_delete_listener, h});

end

function window_delete_listener(window, evd, viewer) %#ok<INUSL>

  viewer.Explorer = [];
  viewer.Visible = 0;
  viewer.NullMessage = viewer.createNullMsg();
   
end
