function setunits(this,property,value)
% SETUNITS is a method that applies the units to the plot. The units are
% obtained from the view preferences. Since this method is plot specific,
% not all fields of the Units structure are used.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:24:13 $

% Prevent negative data ignore warning when switching between abs/logscale
% to dB
[lastmsg,lastid]=lastwarn;
sw = warning('query','MATLAB:Axes:NegativeDataInLogAxis');
warning('off','MATLAB:Axes:NegativeDataInLogAxis')

switch property
case 'FrequencyUnits'
    set(this.AxesGrid,'XUnits',value);
case 'MagnitudeUnits'
    set(this.AxesGrid,'YUnits',value);
case 'FrequencyScale'
    set(this.AxesGrid,'XScale',{value});
case 'MagnitudeScale'
    set(this.AxesGrid,'YScale',{value});
end

warning(sw.state,'MATLAB:Axes:NegativeDataInLogAxis')
lastwarn(lastmsg,lastid);