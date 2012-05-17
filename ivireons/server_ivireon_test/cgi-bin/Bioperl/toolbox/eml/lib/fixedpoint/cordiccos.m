function cos_out = cordiccos(theta, niters)
% CORDICSIN(theta, niters) Compute the CORDIC-based approximation to COS(theta).

% Copyright 2009-2010 The MathWorks, Inc.
%#eml
eml.allowpcode('plain');
eml_prefer_const(theta);
eml_prefer_const(niters);
[~, cos_out] = cordicsincos(theta, niters);
