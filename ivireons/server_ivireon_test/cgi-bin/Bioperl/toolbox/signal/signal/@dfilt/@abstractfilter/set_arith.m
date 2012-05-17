function str = set_arith(h,str)
%SET_ARITH   SetFunction for the Arithmetic property.

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/30 17:33:10 $

if strncmpi(str, 'fixed', length(str)) && ~isfixptinstalled
    error(generatemsgid('invalidArithmetic'), ...
        'A Fixed-Point Toolbox license is required to use fixed-point arithmetic.');
end

h.privArithmetic   = str;
h.privMeasurements = [];

% [EOF]
