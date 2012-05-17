function insigthisfreq = pickFrequencyFromSinestream(in,ctsine,varargin)
%

% PICKFREQUENCYFROMSINESTREAM picks the frequency in sinestream signal in
% at index ctsine and generates the timeseries object that captures signal
% corresponding to that frequency where time starts from origin.
%

%  Author(s): Erman Korkut 26-Mar-2009
%  Revised:
%  Copyright 2003-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:18:43 $

% Compute frequency switch points
[freqswitchpoints,junk] = computeSwitchPoints(in);
freqswitchpoints = [0;freqswitchpoints(:)];
% Generate time series if not given
if nargin > 2
    insig = varargin{1};
else
    insig = generateTimeseries(in);
end
% Write the corresponding portion to the output
insigthisfreq.data = insig.data(1+freqswitchpoints(ctsine):freqswitchpoints(ctsine+1));
insigthisfreq.time = insig.time(1+freqswitchpoints(ctsine):freqswitchpoints(ctsine+1))-...
    insig.time(1+freqswitchpoints(ctsine));
end
