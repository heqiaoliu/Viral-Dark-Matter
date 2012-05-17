function refreshgain(this,action)
% Refreshes plot while dynamically modifying the gain of the edited model.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/04/30 00:37:03 $

%RE: Do not use persistent variables here (several rleditor's
%    might track gain changes in parallel).
switch action
   case 'init'
      % Initialization for dynamic gain update (drag).
      % Switch editor's RefreshMode to quick
      this.RefreshMode = 'quick';
      
      % Install listener on compensator gain only
      C = this.LoopData.EventData.Component;
      this.setEditedBlock(C);
      this.EditModeData = handle.listener(C,findprop(C,'Gain'),...
         'PropertyPostSet',@(x,y) LocalUpdatePlot(this,C));
      
   case 'finish'
      % Return editor's RefreshMode to normal
      this.RefreshMode = 'normal';
      
      % Delete listener
      delete(this.EditModeData);
      this.EditModeData = [];
end


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(this,C)
% Update position of closed-loop poles (magenta squares)

GainMag = getZPKGain(C,'mag');
% Compute closed-loop poles 
this.ClosedPoles = ...
   fastrloc(this.OpenLoopData,GainMag);

% Update red square locations
for ct=1:length(this.ClosedPoles)
   set(this.HG.ClosedLoop(ct),...
      'Xdata',real(this.ClosedPoles(ct)),...
      'Ydata',imag(this.ClosedPoles(ct)))
end



%%%%%%% Update MultiModel bounds
if this.isMultiModelVisible
    CLPolesa = [];
    for ct = 1:length(this.UncertainData)
        CLPolesa = [CLPolesa;fastrloc(this.UncertainData(ct).OpenLoopData,GainMag)];
    end
    this.UncertainBounds.setData(CLPolesa)
end

