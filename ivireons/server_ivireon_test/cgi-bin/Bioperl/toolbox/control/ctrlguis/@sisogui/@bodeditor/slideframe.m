function slideframe(this,action,NewGain)
% Translates Y limits during gain refresh (passive editors).

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2006/06/20 20:02:30 $
Axes = this.Axes;
if strcmp(Axes.YlimMode{1},'manual') || this==this.LoopData.EventData.Editor
    % Quick exit if manual limit or editor currently in use
    return
end

% RE: Used by trackgain & refreshgainC/F 
MagAx = getaxes(Axes);  MagAx = MagAx(1);
MoveData = this.EditModeData;  % persistent move data

switch action
case 'init'
    % Initialize Y limit manager
    MoveData.InitGain = NewGain;   % initial gain (abs)
    MoveData.Ylims = get(MagAx,'Ylim');
    
case 'update'
   % Update limits during move
   OldGain = MoveData.InitGain;
   Ylims = MoveData.Ylims;
   
   if OldGain==0
      % No plot previously shown: set limits
      updateview(this)
      % Reinitialize
      MoveData.InitGain = NewGain;
      MoveData.Ylims = get(MagAx,'Ylim');
      
   else
      GainRatio = NewGain/OldGain;
      if strcmp(Axes.YUnits{1},'abs')
         % Units = abs
         if strcmp(get(MagAx,'Yscale'),'log')
            ylims = log(Ylims);  
         else
            ylims = [log(max(Ylims(1),Ylims(2)/100)) , log(Ylims(2))];
         end
         yTravel = log(GainRatio);
         LimShift = (abs(yTravel)>0.4*(ylims(2)-ylims(1)));
         if LimShift
            % Shift limits
            Ylims = Ylims * GainRatio;
         end
      else
         % Linear scale with dB: compute y travel
         yTravel = 20*log10(GainRatio);
         LimShift = (abs(yTravel)>0.4*(Ylims(2)-Ylims(1)));  
         if LimShift
            % Shift limits
            Ylims = Ylims + yTravel;
         end
      end
      
      if LimShift
         % Update cached data
         MoveData.Ylims = Ylims;
         MoveData.InitGain = NewGain;
         % Set new limits
         % RE: Protected set to avoid any side effects, including change in YlimMode
         Axes.setylim(Ylims,1,'basic');
         Axes.send('PostLimitChanged')
      end
   end
    
end

this.EditModeData = MoveData;
