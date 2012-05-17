function M = setM(h, M)
%SETM validate and set M for QAM demodulator object H.

%   @modem/@qamdemod

%   Copyright 2006 - 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/06 15:49:02 $

% Perform check on common properties of M
baseSetM(h, M);

% Check that M is of the form 2^K
if (ceil(log2(M)) ~= log2(M))
    error([getErrorId(h) ':InvalidM'], ['M must be a finite positive integer ' ...
        'in the form of M = 2^K,\nwhere K is a positive integer.']);
end

% calculate and set affected properties
calcAndSetConstellation(h, M, h.PhaseOffset);

% Update symbol mapping
calcAndSetSymbolMapping(h, M);

% Update soft demodulation rules
initSoftDemod(h, M, h.SymbolMapping);

% Update the process function
setProcessFunction(h, M);

%-------------------------------------------------------------------------------
% [EOF]