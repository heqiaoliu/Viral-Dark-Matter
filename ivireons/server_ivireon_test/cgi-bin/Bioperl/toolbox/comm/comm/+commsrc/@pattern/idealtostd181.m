function idealtostd181(this, tr, tf, hd)
%IDEALTOSTD181 Convert ideal pulse parameters to IEEE STD-181 pulse parameters
%   IDEALTOSTDSTD181(H, TR, TF, HD) converts the ideal pulse parameters TR, TF,
%   and PW to IEEE STD-181 pulse parameters and stores them in the pattern
%   generator object H.  TR is 0% to 100% rise time, TF is 100% to 0% fall time,
%   and HD is high duration of the ideal pulse.
%
%   The IEEE STD-181 standards define a pulse in terms of its
%       * 10% to 90% Rise Time
%       * 90% to 10% Fall Time
%       * 50% Pulse Width
%   The ideal pulse parameters are defined as
%       * 0% to 100% Rise Time
%       * 100% to 0% Fall Time
%       * High duration of the pulse, which is the time duration between the end
%       of the rise of the pulse and the start of the fall of the pulse.
%
%   For a detailed description of the definitions, type 'doc
%   commsrc.pattern/std181toideal'.
%
%   See also COMMSRC.PATTERN, COMMSRC.PATTERN/STD181TOIDEAL,
%   COMMSRC.PATTERN/GENERATE, COMMSRC.PATTERN/RESET, COMMSRC.PATTERN/COMPUTEDCD.
%   COMMSRC.PATTERN/DISP. 

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2008/03/31 17:06:36 $

% Store current values in case we need to restore these
oldRiseTime = this.RiseTime;
oldFallTime = this.FallTime;

% Convert rise and fall times from 100% to 80%, i.e. decrease by 20%
riseTime = tr*0.8;
fallTime = tf*0.8;

% If this is an NRZ pulse, calculate the 50% pulse width for the high symbol
if strncmp(this.PulseType, 'NRZ', 3)
    % Calculate number of samples per symbol
    symbolDuration = hd + tr;
    
    nSamps = this.SamplingFrequency * symbolDuration;
    
    % If nSamps is integer, then this pulse can be realized
    if nSamps ~= fix(nSamps)
        error('comm:commsrc:pattern:NonIntegerSamplesPerSymbol', ...
            ['TR, TF, and PW does not result in integer number of samples '...
            'per symbol.  Pulse is not realizable.  Type ''doc '...
            'commsrc.pattern/std181toideal'' for more details']); 
    end

    % Store current values in case we need to restore these
    oldSampsPerSym = this.SamplesPerSymbol;
    
    try
        this.SamplesPerSymbol = nSamps;
        this.RiseTime = riseTime;
        this.FallTime = fallTime;
    catch exception %#ok
        this.SamplesPerSymbol = oldSampsPerSym;
        this.RiseTime = oldRiseTime;
        this.FallTime = oldFallTime;
        error('comm:commsrc:pattern:InvalidIdealNRZParams', ...
            ['TR, TF, and PW does not result in a valid RZ pulse. '...
            'Type ''doc commsrc.pattern/std181toideal'' for more details.']);
    end
elseif strncmp(this.PulseType, 'RZ', 2)
    % Store current values in case we need to restore these
    oldPulseDur = this.PulseDuration;

    try
        this.PulseDuration = hd + (tr+tf)/2;
        this.RiseTime = riseTime;
        this.FallTime = fallTime;
    catch exception %#ok
        this.PulseDuration = oldPulseDur;
        this.RiseTime = oldRiseTime;
        this.FallTime = oldFallTime;
        error('comm:commsrc:pattern:InvalidIdealRZParams', ...
            ['TR, TF, and PW does not result in a valid RZ pulse. '...
            'Type ''doc commsrc.pattern/std181toideal'' for more details.']);
    end
end

    

%---------------------------------------------------------------------------
% [EOF]