function M = setM(h, M)
%SETM Validate and set M for object H.

%   @modem/@pamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:48:08 $

% Perform check on common properties of M
baseSetM(h, M);

% calculate and set affected properties
calcAndSetConstellation(h, M);

% Update symbol mapping
calcAndSetSymbolMapping(h, M);

% Update soft demodulation rules
initSoftDemod(h, M, h.SymbolMapping);

%-------------------------------------------------------------------------------
% [EOF]