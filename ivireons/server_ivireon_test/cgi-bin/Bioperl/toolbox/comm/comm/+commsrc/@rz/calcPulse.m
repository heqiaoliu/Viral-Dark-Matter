function calcPulse(this)
%CALCPULSE Calculate the pulse parameters needed to generate an RZ pulse
%   CALCPULSE(H) calculates private properties needed to generate an RZ pulse
%   using the RZ pulse generator object THIS.  These properties are:
%       NumRiseSamps
%       RiseRate
%       NumFallSamps
%       FallRate
%       OnDuration
%
%   See also COMMSRC.RZ, COMMSRC.RZ/GENERATE, COMMSRC.RZ/RESET,
%   COMMSRC.RZ/DISP. 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/03/31 17:06:39 $

% Get the on value.
high = this.OutputLevels;

% Calculate rise/fall signal parameters.  Since rise/fall time is defined as 10%
% to 90% rise/fall time, we need to convert it to 0% to 100%.  Note that the
% number of samples does not have to be an integer.
numRiseSamps = this.RiseTime*1.25;         % 10-90 to 0-100 conversion
numFallSamps = this.FallTime*1.25;         % 90-10 to 100-0 conversion
onDuration = this.PulseDuration - (numRiseSamps+numFallSamps)/2;

% Check if this pulse is realizable.  The pulse generator can only generates an
% RZ pulse if the signal has enough time to rise and fall before the next symbol
% starts.  In other words, both the rise time and the fall time must be less
% than the symbol duration.
if ( (numRiseSamps+numFallSamps+onDuration) > this.SymbolDuration )
    error('comm:commsrc:rz:InvalidPulse', ['Pulse is not realizable. ', ...
        'Type ''doc commsrc.pattern'' for valid pulse definitions.'])
end

% Store values
this.OnDuration = onDuration;
this.NumRiseSamps = numRiseSamps;
this.NumFallSamps = numFallSamps;

% Rise/fall rate is the amount of the amplitude increase/decrease per one sample
% time.  We will use this number to determine the amount of amplitude shift
% needed if the rise/fall of the signal does not start at a sampling time but in
% between two sampling points.
if numRiseSamps ~= 0
    this.RiseRate = high/numRiseSamps;
else
    % If rise time is 0, then set rise rate such that the output will reach to
    % high level in one sample time.
    this.RiseRate = high;
end
if numFallSamps ~= 0
    this.FallRate = -high/numFallSamps;
else
    % If fall time is 0, then set fall rate such that the output will reach to
    % low level in one sample time.
    this.FallRate = -high;
end

%---------------------------------------------------------------------------
% [EOF]