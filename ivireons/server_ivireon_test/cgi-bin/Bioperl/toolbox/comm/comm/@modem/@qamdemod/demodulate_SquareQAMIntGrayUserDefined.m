function y = demodulate_SquareQAMIntGrayUserDefined(h, x)
%DEMODULATE_SQUAREQAMINTGRAYUSERDEFINED Demodulate baseband input signal X
% using QAM demodulator object H. Return demodulated integer signal/symbols
% in Y. Gray or user-defined symbol mapping and Square QAM constellation
% are used. 

% @modem/@qamdemod

%   Copyright 2006 - 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/06 15:48:54 $

% Get SymbolMapping and make sure that it has the same orientation as the input.
% Assumes that constellation is a row vector. 
if ( size(x, 2) == 1 )
    symbolMapping = h.SymbolMapping(:);
else
    symbolMapping = h.SymbolMapping;
end

% demodulate considering binary mapping
y = demodulate_SquareQAMIntBin(h, x);

% account for gray/user-defined mapping
y = symbolMapping(y+1);

%-------------------------------------------------------------------------------
% [EOF]        