function str = maketip(this,tip,info)
%MAKETIP  Build data tips for BodeStabilityMarginView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:17 $
AxGrid = info.View.AxesGrid;
str = maketip_p(this,tip,info,AxGrid.XUnits,AxGrid.YUnits{:});
