function checkModInput(h, x)
%CHECKMODINPUT Check modulator input X. H is MODEM.PSKMOD or MODEM.QAMMOD object

% @modem/@abstractmod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/10/10 02:10:09 $

% set status
status = true;

% Check that x is a matrix of real integer numbers
if isempty(x) || ~isreal(x) || any(any(ceil(x) ~= x)) ...
        || ~isnumeric(x) || (length(size(x)) ~= 2) || ~isa(x, 'double')

    status = false;
    errorMsg = 'Input X must be an integer-valued double-precision matrix.';
else
    % Check that x is within range
    if strcmpi(h.InputType, 'integer')
        if ((min(min(x)) < 0) || (max(max(x)) > (h.M-1)))
            status = false;
            errorMsg = 'Elements of input X must be integers in range [0, H.M-1].';
        end
    else
        % h.InputType = 'bit'
        if ((min(min(x)) < 0) || (max(max(x)) > 1))
            status = false;
            errorMsg = 'Elements of input X must be either 0 or 1.';
        end
    end
end

if ~status
    error([getErrorId(h) ':InvalidInput'], errorMsg);
end

%-------------------------------------------------------------------------------

% [EOF]
