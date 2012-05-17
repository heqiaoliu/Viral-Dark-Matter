function numSymbols = set_NumberOfSymbols(this, numSymbols)
%SET_FILTERLENGTH PreSet function for the 'NumberOfSymbols' property

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/10/31 07:02:20 $

if mod(numSymbols*this.SamplesPerSymbol, 2)
    error(generatemsgid('InvalidNumberOfSymbols'),...
        'NumberOfSymbols*SamplesPerSymbol must be even.');
end

% [EOF]
