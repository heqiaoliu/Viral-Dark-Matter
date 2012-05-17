function dim = eml_nonsingleton_dim(x)
%Embedded MATLAB Private Function

%   Finds the first non-singleton dimension of x. Returns 2 (ndims(x)) for
%   scalars to match MATLAB in certain cases (e.g., HISTC, FFT, IFFT).

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
dim = 2;
for k = eml.unroll(1:eml_ndims(x))
    if size(x,k) ~= 1
        dim = k;
        return
    end
end
