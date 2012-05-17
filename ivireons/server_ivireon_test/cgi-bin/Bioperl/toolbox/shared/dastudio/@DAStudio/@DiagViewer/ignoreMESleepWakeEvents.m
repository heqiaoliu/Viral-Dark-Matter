function ignoreMESleepWakeEvents(viewer)
%  ignoreMESleepWakeEvents
%
%  Tells the Diagnostic Viewer's instance of the Model Explorer to ignore
%  sleep/wake events broadcast by itself or other applications. This is
%  necessary to prevent the Explorer instance from responding to 
%  sleep/wake events intended for other instances of the Model Explorer,
%  e.g., THE Model Explorer. See the DV's createExplorer and updateWindow
%  methods for more information.
%  
%  Copyright 2008 The MathWorks, Inc.

  % Tell the Explorer instance to ignore all broadcast events.
  viewer.Explorer.setDispatcherEvents({});
  % viewer.Explorer.setDispatcherEvents({'FocusChangedEvent'});
   
end