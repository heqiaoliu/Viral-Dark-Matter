function h = SinestreamSource(in)
% SINESTREAMSOURCE Constructor for @SinestreamSource class

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:50:03 $
% 

% Create the class instance
h = frestviews.SinestreamSource;

% Compute switching points from input signal
[h.FreqSwitchInd,h.SSSwitchInd] = computeSwitchPoints(in);

% Compute sample times from input signal
h.Ts = 1./unitconv(in.Frequency,in.FreqUnits,'Hz')./in.SamplesPerPeriod;