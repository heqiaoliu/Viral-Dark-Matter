function dcd = computedcd(this)
%COMPUTEDCD Compute the duty cycle distortion (DCD)
%   DCD = COMPUTEDCD(H) computes the duty cycle distortion, DCD, of the pulse
%   defined by the pattern generator object H.
%
%   DCD is defined as the ratio of the on duration of the pulse to the off
%   duration of the pulse.  For an NRZ pulse, on duration is the duration the
%   pulse spends above zero level.  Off duration is the duration the pulse
%   spends below zero.  
%
%   For a detailed description of the duty cycle distortion, type 'doc
%   commsrc.pattern/computedcd'.
%
%   See also COMMSRC.PATTERN, COMMSRC.PATTERN/IDEALTOSTD181,
%   COMMSRC.PATTERN/STD181TOIDEAL, COMMSRC.PATTERN/GENERATE,
%   COMMSRC.PATTERN/RESET, COMMSRC.PATTERN/DISP. 

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2008/03/31 17:06:35 $

if strncmp(this.PulseType, 'RZ', 2)
    error('comm:commsrc:pattern:DCDForRZ', ['Duty cycle distortion is not '...
        'defined for RZ pulses.']);
end

% Calculate 0% to 100% rise and fall times
riseTime = this.RiseTime*1.25;
fallTime = this.FallTime*1.25;

% Calculate the time the pulse spends on high and low levels
symbolDuration = 1/this.SymbolRate;
highTime = symbolDuration - riseTime;
lowTime = symbolDuration - fallTime;

% Calculate the contibution of rise and fall times to the on and off durations
outputLevels = this.OutputLevels;
highLevel = max(outputLevels);
lowLevel = min(outputLevels);

ratio1 = (highLevel-lowLevel)/highLevel;
ratio2 = (highLevel-lowLevel)/lowLevel;

% Calculate on and off durations
onTime = ratio1*(riseTime+fallTime)+highTime;
offTime = ratio2*(riseTime+fallTime)+lowTime;

% Calculate DCD
dcd = onTime / offTime;

%---------------------------------------------------------------------------
% [EOF]