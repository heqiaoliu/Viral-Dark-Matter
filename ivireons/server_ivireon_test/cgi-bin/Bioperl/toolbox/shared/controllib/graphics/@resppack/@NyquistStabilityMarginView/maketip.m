function str = maketip(this,tip,info)
%MAKETIP  Build data tips for NyquistStabilityMarginView Characteristics.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:53 $
h = info.Carrier.Parent; % plot handle
% UDDREVISIT
str = maketip_p(this,tip,info,h.FrequencyUnits,h.MagnitudeUnits,h.PhaseUnits);
