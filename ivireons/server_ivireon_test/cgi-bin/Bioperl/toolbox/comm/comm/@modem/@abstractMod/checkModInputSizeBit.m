function  checkModInputSizeBit(h, x)
%CHECKMODINPUTSIZEBIT Check size of modulator binary/bit input X. H is
%MODEM.PSKMOD or MODEM.QAMMOD object

% @modem/@abstractmod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:45:36 $

% number of elements in each channel/column of input must be an integer multiple of log2(h.M)
nbits = log2(h.M);
if (mod(size(x, 1), nbits) ~= 0)
    error([getErrorId(h) ':InvalidInputSize'], ['Number of elements in each ' ...
        'channel of input X must be an integer multiple of log2(M).']);
end

%-------------------------------------------------------------------------------

% [EOF]