function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @sigmaview curves.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:24:21 $

r = info.Carrier;
AxGrid = info.View.AxesGrid;

% Create tip text
str = {sprintf('Response: %s',r.Name);...
      sprintf('Frequency (%s): %0.3g', AxGrid.XUnits, tip.Position(1)); ...
      sprintf('Singular Value (%s): %0.3g', AxGrid.YUnits, tip.Position(2))}; 
