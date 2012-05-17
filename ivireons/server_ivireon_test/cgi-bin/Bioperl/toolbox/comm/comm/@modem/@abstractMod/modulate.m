function y = modulate(h, x)
%MODULATE Modulate input X using modulator object H.

% @modem/@abstractMod

%   Copyright 2006 - 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/06 15:46:37 $

% Check input signal
checkModInput(h, x);

% Call method to perform modulation
y = feval(h.ProcessFunction, h, x);
    
% Force output to be complex 
if ( isreal(y) )
    y = complex(y);
end
%-------------------------------------------------------------------------------
% [EOF]        