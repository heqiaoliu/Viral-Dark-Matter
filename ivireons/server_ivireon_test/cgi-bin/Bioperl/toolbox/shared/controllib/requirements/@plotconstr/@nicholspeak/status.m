function Status = status(Constr, Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:30 $

XUnits = Constr.PhaseUnits;
YUnits = Constr.MagnitudeUnits;
PhaseOrigin = unitconv(Constr.OriginPha, 'deg', XUnits);
PeakGain    = unitconv(Constr.PeakGain,   'dB', YUnits);

switch Context
 case 'move'
  % Status update when completing move
  Status = sprintf('New peak gain requirement is %0.3g %s at %0.3g %s.', ...
		   PeakGain, YUnits, PhaseOrigin, XUnits);
  
 case 'resize'
  % Post new slope
  Status = sprintf('New peak gain requirement is %0.3g %s at %0.3g %s.', ...
		   PeakGain, YUnits, PhaseOrigin, XUnits);
  
 case 'hover'
  % Status when hovered
  str = sprintf('Design requirement: closed-loop peak gain < %0.3g %s at %0.3g %s.', ...
		PeakGain, YUnits, PhaseOrigin, XUnits);
  Status = sprintf('%s\nLeft-click and drag to move this requirement.', str);
  
 case 'hovermarker'
  % Status when hovering over markers
  str = sprintf('Design requirement: closed-loop peak gain < %0.3g %s at %0.3g %s.', ...
		PeakGain, YUnits, PhaseOrigin, XUnits);
  Status = sprintf('%s\nLeft-click and drag to resize this requirement.', str);
end
