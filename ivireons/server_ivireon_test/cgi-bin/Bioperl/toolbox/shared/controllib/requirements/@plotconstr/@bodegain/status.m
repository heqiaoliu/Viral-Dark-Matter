function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:31:26 $

XUnits = Constr.getDisplayUnits('XUnits');
Freqs = unitconv(Constr.Frequency(Constr.SelectedEdge,:),Constr.FrequencyUnits,XUnits);

switch Context
case 'move'
    % Status update when completing move
    if numel(Constr.SelectedEdge) > 1
       Status = sprintf('New gain requirement location is from %0.3g to %0.3g %s.',...
          min(min(Freqs)),max(max(Freqs)),XUnits);
    else
       Status = sprintf('New gain requirement segment location is from %0.3g to %0.3g %s.',...
          min(Freqs),max(Freqs),XUnits);
    end
case 'resize'
    % Post new slope
    LocStr = sprintf('The gain requirement segment new location is from %0.3g to %0.3g %s',...
        min(min(Freqs)),max(max(Freqs)),XUnits);
    SlopeStr = sprintf('with a slope of %0.3g dB/decade.',slope(Constr,Constr.SelectedEdge));
    Status = sprintf('%s\n%s',LocStr,SlopeStr);    
case 'hover'
    % Status when hovered
    Type = Constr.Type;  Type(1) = upper(Type(1));
    if numel(Constr.SelectedEdge) > 1
       Description = sprintf('%s gain limit with frequency range from %0.3g to %0.3g %s.',Type,...
          min(min(Freqs)),max(max(Freqs)),XUnits);
    else
       Description = sprintf('%s gain limit with slope %0.3g dB/decade.',Type,...
          slope(Constr,Constr.SelectedEdge));
    end
    Status = sprintf('%s\nLeft-click and drag to move this gain requirement.',Description);   
case 'hovermarker'
    % Status when hovering over markers
    Status = sprintf('Select and drag to adjust extent and slope of gain requirement segment.');
end

