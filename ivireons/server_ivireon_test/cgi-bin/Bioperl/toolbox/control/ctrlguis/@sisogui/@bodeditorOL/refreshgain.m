function refreshgain(this,action)
% Refreshes plot during dynamic edit of local compensator's gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2010/04/30 00:36:45 $

%RE: Do not use persistent variables here (several instance of this 
%    editor may track gain changes in parallel).
switch action
   
   case 'init'
      % Initialization for dynamic gain update (drag)
      % Switch editor's RefreshMode to quick
      this.RefreshMode = 'quick';
      
      % Get initial Y location of poles/zeros (for normalized edited model)
      hPZ = [this.HG.Compensator.Magnitude; this.HG.System.Magnitude];
      W = get(hPZ,{'Xdata'});
      W = unitconv(cat(1,W{:}),this.Axes.XUnits,'rad/sec');
      MagPZ = this.interpmag(this.Frequency,this.Magnitude,W);  % in abs units
      
      % Install listener on compensator gain (save ref in EditModeData)
      C = this.LoopData.EventData.Component; % edited compensator
      this.setEditedBlock(C);
      this.EditModeData = struct('GainListener',...
         handle.listener(C,findprop(C,'Gain'),...
         'PropertyPostSet',{@LocalUpdatePlot this C MagPZ hPZ}));
      
      % Initialize Y limit manager
      % RE: Does nothing for editor currently in use (see trackgain)
      this.slideframe('init',getZPKGain(C,'mag'));
      
   case 'finish'
      % Return editor's RefreshMode to normal
      this.RefreshMode = 'normal';
      
      % Delete listener and clear mode data
      delete(this.EditModeData.GainListener);
      this.EditModeData = [];
      
end


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(hSrcProp,event,this,C,MagPZ,hPZ)
% Updates mag curve position

% Adjust position of magnitude plot
NewGain = getZPKGain(C,'mag'); 

% Update magnitude plot
% RE: Gain sign can't change in drag mode!
MagUnits = this.Axes.YUnits{1};
set(this.HG.BodePlot(1),'Ydata',...
    unitconv(this.Magnitude * NewGain,'abs',MagUnits))
Ypz = unitconv(MagPZ * NewGain,'abs',MagUnits);
for ct=1:length(hPZ)
    set(hPZ(ct),'Ydata',Ypz(ct))
end

%%%%%%% Update MultiModel bounds
if this.isMultiModelVisible
    this.UncertainBounds.setData(NewGain*this.UncertainData.Magnitude,...
        this.UncertainData.Phase,this.UncertainData.Frequency)
end

% Update stability margins (using interpolation)
refreshmargin(this)

% Update Y limits
this.slideframe('update',NewGain)





