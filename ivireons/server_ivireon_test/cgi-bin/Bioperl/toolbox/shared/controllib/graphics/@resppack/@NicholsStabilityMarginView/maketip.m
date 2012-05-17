function str = maketip(this,tip,info)
%MAKETIP  Build data tips for NicholsStabilityMarginView Characteristics.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:42 $
AxGrid = info.View.AxesGrid;
r = info.Carrier;
% UDDREVISIT
str = maketip_p(this,tip,info,r.Parent.FrequencyUnits,AxGrid.YUnits,AxGrid.XUnits);
