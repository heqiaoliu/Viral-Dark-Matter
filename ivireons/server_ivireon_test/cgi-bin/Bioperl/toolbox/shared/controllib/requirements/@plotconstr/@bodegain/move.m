function [X,Y] = move(Constr,action,X,Y,X0,Y0)
%MOVE  Moves constraint
% 
%   [X0,Y0] = CONSTR.MOVE('init',X0,Y0) initialize the move. The 
%   pointer may be slightly moved to sit on the constraint edge
%   and thus eliminate distortions due to patch thickness.
%
%   [X,Y] = CONSTR.MOVE('restrict',X,Y,X0,Y0) limits the displacement
%   to locations reachable by CONSTR.
%
%   STATUS = CONSTR.MOVE('update',X,Y,X0,Y0) moves the constraint.
%   For constraints indirectly driven by the mouse, the update is
%   based on a displacement (X0,Y0) -> (X,Y) for a similar constraint 
%   initially sitting at (X0,Y0).

%   Author(s): N. Hickey, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:31:22 $

% RE: Incremental move is not practical because the constraint cannot
%     track arbitrary mouse motion (e.g., enter negative gain zone)

hGroup  = Constr.Elements;
HostAx  = handle(hGroup.Parent);
XUnits  = Constr.getDisplayUnits('XUnits');
YUnits  = Constr.getDisplayUnits('YUnits');
Ylinabs = strcmp(YUnits,'abs') & strcmp(HostAx.Yscale,'linear');

switch action
case 'init'
   % Initialization
   if Ylinabs 
      % If the mouse is selecting this constraint, move pointer to (X0,Y(X0) 
      % to avoid distortions due to patch thickness
      HostFig = HostAx.Parent;
      hChildren = hGroup.Children;
      Tags = get(hChildren,'Tag');
      idx = strcmp(Tags,'ConstraintPatch');
      if hChildren(idx)==hittest(HostFig)
         Y = unitconv(Constr.Magnitude(Constr.SelectedEdge,1),Constr.YUnits,'abs') * ...
            (X/unitconv(Constr.Frequency(Constr.SelectedEdge,1),Constr.XUnits,XUnits))^(Constr.slope/20);
         % Move pointer to new (X0,Y0)
         moveptr(HostAx,'init')
         moveptr(HostAx,'move',X,Y);
      end
   end
   % Model is
   %    Freq = Freq0 * (X/X0)
   %    Mag = Mag0 + (YdB-Y0dB)
   % RE: Don't save (X0,Y0) here as it may be modified by other selected 
   %     constraint during init
   Constr.AppData = struct(...
      'Freq0',unitconv(Constr.Frequency(Constr.SelectedEdge,:),Constr.XUnits,Constr.getDisplayUnits('XUnits')),...
      'Mag0' ,unitconv(Constr.Magnitude(Constr.SelectedEdge,:),Constr.YUnits,Constr.getDisplayUnits('YUnits')) );
   
case 'restrict'
   % Restrict displacement (X0,Y0)->(X,Y) to account for constraints on mag and freq.
   if strcmp(HostAx.Xscale,'linear')
      X = max(X,1e-3*max(HostAx.Xlim));  % prevent negative freq
   end
   if Constr.Ts
      X = min(X,(X0/Constr.AppData.Freq0(2))*pi/Constr.Ts);  % stay left of Nyquist freq
   end
   if Ylinabs
      Y = max(Y,1e-3*max(HostAx.Ylim));  % prevent negative gain
   end

   %If part of a bound, check to prevent move beyond neighbours extremes.
   if size(Constr.xCoords,1)>1
      minSize  = eps;
      iElement = Constr.SelectedEdge;
      if iElement < size(Constr.xCoords,1)
         X = min(X, X0/Constr.AppData.Freq0(2) * ...
            unitconv(Constr.Frequency(iElement+1,2),Constr.XUnits,Constr.getDisplayUnits('XUnits'))*...
            (1-minSize*sign(Constr.Frequency(iElement+1,2))));
      end
      if iElement > 1
         X = max(X, X0/Constr.AppData.Freq0(1) * ...
            unitconv(Constr.Frequency(iElement-1,1),Constr.XUnits,Constr.getDisplayUnits('XUnits'))*...
            (1+minSize*sign(Constr.Frequency(iElement-1,1))));
      end
   end
   
case 'update'
   iElement = Constr.SelectedEdge;
   
   % Update magnitude. 
   Constr.Magnitude(iElement,:) = unitconv(Constr.AppData.Mag0 + ...
      diff(unitconv([Y0 Y],Constr.getDisplayUnits('YUnits'),YUnits)),...
      Constr.getDisplayUnits('YUnits'), Constr.MagnitudeUnits);
   % Update frequency, preserving its X extent in decades
   Constr.Frequency(iElement,:) = unitconv(Constr.AppData.Freq0 * (X/X0),...
      Constr.getDisplayUnits('XUnits'),Constr.FrequencyUnits);
  
   %Manually force coordinate updates and redraw
   Constr.Data.updateCoords(Constr.Orientation,false);
   Constr.update;
   
   % Status
   Freqs = unitconv(Constr.Frequency(iElement,:),Constr.FrequencyUnits,XUnits);
   LocStr = sprintf('Current location:  from %0.3g to %0.3g %s',Freqs(1),Freqs(2),XUnits);
   X = sprintf('Move requirement to desired location and release the mouse.\n%s',LocStr); 
  
case 'finish'
   %Notify listeners of data source change
   Constr.Data.send('DataChanged');
end