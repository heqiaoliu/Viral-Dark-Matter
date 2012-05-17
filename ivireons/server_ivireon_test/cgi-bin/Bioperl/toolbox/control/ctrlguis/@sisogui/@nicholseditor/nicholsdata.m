function [Gain, Mag, Pha, Freq] = nicholsdata(this)
%NICHOLSDATA  Gain, Magnitude, Phase, and Frequency data in current units

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.9.4.2 $  $Date: 2007/11/09 19:48:24 $

% REVISIT

% Convert Nichols data to current units
L = getL(this);

Gain = getZPKGain(this.EditedBlock,'mag'); 
Mag  = mag2db(this.Magnitude * Gain);
Pha  = unitconv(this.Phase, 'deg', this.Axes.XUnits);
Freq = unitconv(this.Frequency, 'rad/sec', this.FrequencyUnits);
