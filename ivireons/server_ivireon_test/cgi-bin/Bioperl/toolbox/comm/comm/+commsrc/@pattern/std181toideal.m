function [tr tf hd] = std181toideal(this)
%STD181TOIDEAL Convert IEEE STD-181 pulse parameters to ideal pulse parameters
%   [TR TF HD] = STDSTD181TOIDEAL(H) converts the pulse parameters stored in the
%   pattern generator object H to ideal pulse parameters.  The pattern generator
%   stores the pulse parameters in IEEE STD-181 format.  TR is 0% to 100% rise
%   time, TF is 100% to 0% fall time, and HD is the high duration of the ideal
%   pulse.
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
%   See also COMMSRC.PATTERN, COMMSRC.PATTERN/IDEALTOSTD181,
%   COMMSRC.PATTERN/GENERATE, COMMSRC.PATTERN/RESET, COMMSRC.PATTERN/COMPUTEDCD.
%   COMMSRC.PATTERN/DISP. 

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2008/03/31 17:06:38 $

% Convert rise and fall times from 80% to 100%, i.e. increase by 25%
tr = this.RiseTime * 1.25;
tf = this.FallTime * 1.25;

% If this is an NRZ pulse, calculate the 50% pulse width for the high symbol
if strncmp(this.PulseType, 'NRZ', 3)
    hd = 1/this.SymbolRate - tr;
elseif strncmp(this.PulseType, 'RZ', 2)
    hd = this.PulseDuration - (tr+tf)/2;
end
%---------------------------------------------------------------------------
% [EOF]