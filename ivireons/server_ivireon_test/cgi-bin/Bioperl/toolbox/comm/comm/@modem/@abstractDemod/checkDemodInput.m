function checkDemodInput(h, x)
%CHECKDEMODINPUT Check demodulator input X. H is MODEM.PSKDEMOD or MODEM.QAMDEMOD object

% @modem/@abstractdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/10 02:10:06 $

% set status
status = true;

% Check that x is a matrix of double numbers
if ~isnumeric(x) || (length(size(x)) ~= 2) || ~isa(x, 'double')
    status = false;
    errorMsg = 'Input X must be a double-precision matrix.';
end

if ~status
    error([getErrorId(h) ':InvalidInput'], errorMsg);
end

%-------------------------------------------------------------------------------

% [EOF]
