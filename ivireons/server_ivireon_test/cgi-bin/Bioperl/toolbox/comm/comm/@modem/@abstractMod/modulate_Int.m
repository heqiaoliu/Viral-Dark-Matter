function y = modulate_Int(h, x)
%MODULATE_INT Modulate symbol/integer signal X using modulator object H. 
% Return baseband modulated signal Y.

% @modem/@abstractMod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/10/10 02:10:13 $

% compute output
y = computeModOutput(h, x);

%--------------------------------------------------------------------
% [EOF]
