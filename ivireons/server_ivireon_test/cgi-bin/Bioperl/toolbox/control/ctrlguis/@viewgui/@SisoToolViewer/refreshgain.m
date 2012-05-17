function refreshgain(this,LoopData)
%REFRESHGAIN  Refreshes plot during dynamic edit of compensator gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2010/03/26 17:22:58 $

%RE: Do not use persistent variables here (several viewers
%    might track gain changes in parallel).

switch LoopData.EventData.Phase
case 'init'
   % Initialization for dynamic gain update (drag).
   [RealTimeData,idxSys] = moveInit(this);
   
   % Install listener on compensator gain
   C = LoopData.EventData.Component;
   RealTimeData.DataListener = handle.listener(C,findprop(C,'Gain'),...
       'PropertyPostSet',{@LocalUpdatePlot LoopData this.Systems(idxSys) this.SystemInfo(idxSys)});
    
   % Save data need for clean up (moveFinish)
   this.RealTimeData = RealTimeData;
   
case 'finish'
   % Return editor's RefreshMode to normal
   moveFinish(this)
   this.RealTimeData = [];

   % Clear data cached in lti sources
   resetsys(this)
end


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(hSrcProp,event,LoopData,VisibleSystems,VisibleSystemInfo)
% Updates visible models (SourceChanged listeners will do the rest)
for ct=1:length(VisibleSystems)
   [Model,UncertainModel] = LoopData.getmodel(VisibleSystemInfo(ct));
    VisibleSystems(ct).UncertainModel = UncertainModel;
%    VisibleSystems(ct).UncertainModel = Model;
   VisibleSystems(ct).Model = Model;
end