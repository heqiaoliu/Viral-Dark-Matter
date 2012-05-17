function installWindowCloseListener(h)
%  installWindowCloseListener
%  Installs a listener for diagnostic viewer window (i.e., Explorer) close
%  events.

%  Copyright 2008 The MathWorks, Inc.
  

h.hCloseListener = handle.listener(h.Explorer, 'MEPostClosed', ...
  {@closeHandler, h});

end

function closeHandler(hExplorer, e, viewer)

  viewer.Visible = false;
  
end
