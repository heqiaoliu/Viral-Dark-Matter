function sf = cordic_compute_gain(niters)
%CORDIC_COMPUTE_GAIN Return the CORDIC algorithm gain (scale factor) value
%   Usage: sf = cordic_compute_gain(niters)
%
%   Notes: sf is returned as a double.

% Copyright 2010 The MathWorks, Inc.
%#eml

if ~isempty(eml.target)
    eml_prefer_const(niters);
end

intArray = (0:(double(niters)-1))';
sf       = prod(sqrt(1 + 2.^(-2*intArray)));

end

% LocalWords:  niters
