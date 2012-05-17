function y = demodulate_IntBin(h, x)
%DEMODULATE_BITBIN Demodulate baseband input signal X using DPSK demodulator object H.  
% Return demodulated integer signal/symbols Y. Binary symbol mapping is used.

% @modem/@dpskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:46:59 $

% Get PhaseRotation
phaseRotation = h.PrivPhaseRotation;

% Get the initial phase
initPhase = h.PrivPhaseState;
if ( size(initPhase, 2) ~= size(x,2) )
    h.InitialPhase = zeros(1, size(x,2));
    initPhase = h.InitialPhase;
    warning([getErrorId(h) ':InvalidInitPhase'], ...
        'InitialPhase vector is set to 0 for all the channels.');
end;

% Get M
M = h.M;

% Normalization factor to convert from PI-domain to linear domain
normFactor = M/(2*pi); 

% Calculate the phase difference
symPhase = diff(unwrap([initPhase; angle(x)])) - phaseRotation;

% Convert input signal angle to linear domain; round the value to get ideal
% constellation points 
% Note: To be consistent with the blockset, we map 0.5 to 0 using ceil(x-0.5).
% If minimum distance is computed in a for loop and two constellation points
% resulted in the same distance, the first one (or the one with the smallest
% index) is be selected. 
y = ceil(symPhase * normFactor - 0.5);

% Move all the negative integers by M
y(y < 0) = M + y(y < 0);

% Store the last phase
h.PrivPhaseState = angle(x(end, :));

%--------------------------------------------------------------------
% [EOF]        