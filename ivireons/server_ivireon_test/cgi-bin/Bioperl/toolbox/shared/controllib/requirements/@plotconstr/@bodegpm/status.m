function Status = status(Constr, Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): A. Stothert
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:31:34 $

PhaseUnits = Constr.PhaseUnits;
MagUnits   = Constr.MagnitudeUnits;
MarginGain = unitconv(Constr.MarginGain, 'db', MagUnits);
MarginPha  = unitconv(Constr.MarginPha, 'deg', PhaseUnits);

Status = sprintf('Gain margin > %0.3g %s, Phase margin > %0.3g %s.', ...
   MarginGain, MagUnits, MarginPha, PhaseUnits);
