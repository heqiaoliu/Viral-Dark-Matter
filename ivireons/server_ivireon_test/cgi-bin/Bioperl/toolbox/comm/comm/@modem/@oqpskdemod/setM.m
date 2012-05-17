function M = setM(h, M)
%SETM Validate and set M for object H.
%   OQPSK M value is constant and set to 4.
%
%   @modem/@oqpskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:29 $

% For OQPSK M must be 4
if (M ~= 4)
    M = 4;
    warning([getErrorId(h) ':MMustBe4'], 'M must be 4 for OQPSK and is set accordingly.');
end;

% Calculate and set affected properties
% Update Constellation
calcAndSetConstellation(h, h.PhaseOffset);

% Update symbol mapping
calcAndSetSymbolMapping(h, M);

% Update soft demodulation rules
initSoftDemod(h, M, h.SymbolMapping);

%-------------------------------------------------------------------------------
% [EOF]