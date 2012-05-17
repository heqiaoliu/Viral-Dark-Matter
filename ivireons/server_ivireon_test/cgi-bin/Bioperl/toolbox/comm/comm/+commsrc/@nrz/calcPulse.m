function calcPulse(this)
%CALCPULSE Calculate the pulse parameters needed to generate an NRZ pulse
%   CALCPULSE(H) calculates private properties needed to generate an NRZ
%   pulse using the NRZ pulse generator object H.  These properties are:
%       NumRiseSamps
%       RiseRate
%       HighLevel
%       NumFallSamps
%       FallRate
%       LowLevel
%
%   See also COMMSRC.NRZ, COMMSRC.NRZ/GENERATE, COMMSRC.NRZ/RESET,
%   COMMSRC.NRZ/DISP. 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/03/31 17:06:32 $

% Get high and low values.  We assume that there are two levels
low = min(this.OutputLevels);
high = max(this.OutputLevels);

% Calculate rise/fall signal parameters.  Since rise/fall time is defined as 10%
% to 90% rise/fall time, we need to convert it to 0% to 100%.  Note that the
% number of samples does not have to be an integer.
numRiseSamps = this.RiseTime*1.25;         % 10-90 to 0-100 conversion
numFallSamps = this.FallTime*1.25;         % 90-10 to 100-0 conversion

% Check if this pulse is realizable.  The pulse generator can only generates and
% NRZ pulse if the signal has enough time to rise or fall before the next symbol
% starts.  In other words, both the rise time and the fall time must be less
% than the symbol duration.
if ( numRiseSamps > this.SymbolDuration )
    error('comm:commsrc:nrz:InvalidTrTsym', ['RiseTime must be less then ' ...
        'or equal to SymbolDuration.'])
end
if ( numFallSamps > this.SymbolDuration )
    error('comm:commsrc:nrz:InvalidTfTsym', ['FallTime must be less then ' ...
        'or equal to SymbolDuration.'])
end
                                        
% Store values
this.NumRiseSamps = numRiseSamps;
this.NumFallSamps = numFallSamps;
this.HighLevel = high;
this.LowLevel = low;

% Rise/fall rate is the amount of the amplitude increase/decrease per one sample
% time.  We will use this number to determine the amount of amplitude shift
% needed if the rise/fall of the signal does not start at a sampling time but in
% between two sampling points.
if numRiseSamps ~= 0
    this.RiseRate = (high-low)/numRiseSamps;
else
    % If rise time is 0, then set rise rate such that the output will reach to
    % high level in one sample time.
    this.RiseRate = (high-low);
end
if numFallSamps ~= 0
    this.FallRate = (low-high)/numFallSamps;
else
    % If rise time is 0, then set fall rate such that the output will reach to
    % low level in one sample time.
    this.FallRate = (low-high);
end

%---------------------------------------------------------------------------
% [EOF]