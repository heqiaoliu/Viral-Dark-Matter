function y = computeModOutput(h, x)
%COMPUTEMODOUTPUT Compute modulator output for modulator object H. 

% @modem/@dpskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:13 $

% Get input size
[numSymbols numChans] = size(x);

% Get PhaseRotation
phaseRotation = h.PhaseRotation;

% Get the initial phase
initPhase = h.PrivPhaseState;
if ( size(initPhase, 2) ~= numChans )
    h.InitialPhase = zeros(1, numChans);
    initPhase = h.InitialPhase;
    warning([getErrorId(h) ':InvalidInitPhase'], ...
        'InitialPhase vector is set to 0 for all the channels.');
end;

% Get constellation and make sure that it has the same orientation as the
% input.  Assumes that constellation is a row vector.
if ( size(x, 2) == 1 )
    constellation = angle(h.Constellation(:));
else
    constellation = angle(h.Constellation);
end

% Get transformed mapping
mapping = h.TransSymMapping;

% Prepend the input with initial phase, add the phaseRotation
xPhase = [initPhase; phaseRotation + constellation(mapping(x+1))];

% Compute output
symPhase = cumsum(xPhase);

% First symbol in each channel is the prepended initial phase, which has already
% been sent or known by the receiver.  So remove that symbol.
y = exp(j*symPhase(2:end,:));

% Store the last phase
h.PrivPhaseState = mod(symPhase(end,:), 2*pi);

%--------------------------------------------------------------------
% [EOF]