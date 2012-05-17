function y = demodulate_IntGrayUserDefined(h, x)
%DEMODULATE_INTGRAYUSERDEFINED Demodulate baseband input signal X using DPSK
%   demodulator object H. Return demodulated symbols/integers in Y. Gray or 
%	user-defined symbol mapping is used.

% @modem/@dpskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:00 $

% Get SymbolMapping and make sure that it has the same orientation as the input.
% Assumes that constellation is a row vector. 
if ( size(x, 2) == 1 )
    symbolMapping = h.SymbolMapping(:);
else
    symbolMapping = h.SymbolMapping;
end

% demodulate considering binary mapping
y = demodulate_IntBin(h, x);

% account for gray/user-defined mapping
y = symbolMapping(y+1);

%--------------------------------------------------------------------
% [EOF]        