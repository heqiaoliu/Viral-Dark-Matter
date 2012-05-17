function sin_out = cordicsin(theta, niters)
% CORDICSIN(theta, niters) Compute the CORDIC-based approximation to SIN(theta).

% Copyright 2009-2010 The MathWorks, Inc.
%#eml
eml.allowpcode('plain');
eml_prefer_const(theta);
eml_prefer_const(niters);
sin_out = cordicsincos(theta, niters);
