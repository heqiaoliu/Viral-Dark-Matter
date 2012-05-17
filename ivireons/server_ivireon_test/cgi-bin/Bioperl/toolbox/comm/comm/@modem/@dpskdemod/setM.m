function M = setM(h, M)
%SETM Validate and set M for object H.

%   @modem/@dpskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/06/08 15:52:50 $

% Perform check on common properties of M
baseSetM(h, M);

% Calculate and set affected properties
calcAndSetConstellation(h, M);

% Update symbol mapping
calcAndSetSymbolMapping(h, M);

% Reset
reset(h);

%-------------------------------------------------------------------------------
% [EOF]