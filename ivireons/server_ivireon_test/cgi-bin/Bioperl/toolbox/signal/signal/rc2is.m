function inv_sin = rc2is(k)
%RC2IS Convert reflection coefficients to inverse sine parameters.
%   INV_SIN = RC2IS(K) returns the inverse sine parameters corresponding 
%   to the reflection coefficients, K.
%
%   See also IS2RC, RC2POLY, RC2AC, RC2LAR.

%   Reference: J.R. Deller, J.G. Proakis, J.H.L. Hansen, "Discrete-Time 
%   Processing of Speech Signals", Prentice Hall, Section 7.4.5.
%
%   Author(s): A. Ramasubramanian
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2007/12/14 15:05:51 $

if ~isreal(k),
 error(generatemsgid('NotSupported'),'Inverse sine parameters not defined for complex reflection coefficients.');
end           

if max(abs(k)) >= 1,
    error(generatemsgid('InvalidRange'),'All reflection coefficients should have magnitude less than unity.');
end

inv_sin = (2/pi)*asin(k);

% [EOF] rc2is.m
