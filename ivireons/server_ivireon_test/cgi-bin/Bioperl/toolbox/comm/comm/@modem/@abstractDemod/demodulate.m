function y = demodulate(h, x)
%DEMODULATE Demodulate input X using demodulator object H.

% @modem/@abstractDemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/10/10 02:10:07 $

% Check input
checkDemodInput(h, x);

% Call method to perform demodulation
y = feval(h.ProcessFunction, h, x);
    
%-------------------------------------------------------------------------------
% [EOF]