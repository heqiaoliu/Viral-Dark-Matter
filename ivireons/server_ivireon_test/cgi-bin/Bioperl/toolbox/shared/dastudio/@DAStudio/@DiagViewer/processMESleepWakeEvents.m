function processMESleepWakeEvents(viewer)
%  ignoreMESleepWakeEvents
%
%  Tells the Diagnostic Viewer's instance of the Model Explorer to process
%  sleep/wake events broadcast by itself or other applications. This
%  with the DV's ignoreMESleepWakeEvents method allows the DV to prevent
%  its Explorer instance from responding to broadcast sleep/wake events  
%  intended for other ME-based GUIs, such as THE Model Explorer.  See the 
%  DV's createExplorer and updateWindow methods for more information.
%  
%  Copyright 2008 The MathWorks, Inc.

  viewer.Explorer.setDispatcherEvents({'MESleepEvent' 'MEWakeEvent'});

   
end