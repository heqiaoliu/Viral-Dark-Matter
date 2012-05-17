function y = pctdemo_aux_quadpi(x)
%PCTDEMO_AUX_QUADPI Return data to approximate pi.
%   Helper function used to approximate pi.  This is the derivative 
%   of 4*atan(x).

%   Copyright 2008 The MathWorks, Inc.
y = 4./(1 + x.^2);
