function sleepExplorer(viewer)
%  sleepExplorer
%
%  Tells the Diagnostic Viewer's instance of the Model Explorer to ignore
%  events broadcast by itself or other applications.
%  
%  Copyright 2008 The MathWorks, Inc.

  % The DV's Explorer instance ignores sleep events by default.
  % So, we need to turn on sleep event processing here.
  viewer.processMESleepWakeEvents();
  ed = DAStudio.EventDispatcher;
  ed.broadcastEvent('MESleepEvent');

end