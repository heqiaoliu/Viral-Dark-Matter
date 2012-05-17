function wakeExplorer(viewer)
%  wakeExplorer
%
%  Wakes the Diagnostic Viewer's instance of the Model Explorer. This
%  causes the instance to refresh itself if it has previously been 
%  asleep. This method should be used only after a call to the
%  sleepExplorer method.
%  
%  Copyright 2008 The MathWorks, Inc.

  ed = DAStudio.EventDispatcher;
  ed.broadcastEvent('MEWakeEvent');
  
  % Turn off ME sleep event listening to prevent the DV's Explorer 
  % instance from responding to broadcast sleep/wake events intended
  % for other applications.
  viewer.ignoreMESleepWakeEvents();
  
end