function dim = eml_const_nonsingleton_dim(x)
%Embedded MATLAB Private Function

%   Finds the first non-singleton or variable dimension of x. Returns 2
%   (ndims(x)) for scalars to match MATLAB in certain cases (e.g., HISTC,
%   FFT, IFFT). The result will be a constant. In most cases a call to this
%   function should be followed by an eml_lib_assert to generate an error
%   message if a variable length dimension takes on the length of 1, since
%   in that case MATLAB will select another dimension (unless the x is
%   scalar). A typical example would be:
%
%   eml_lib_assert(eml_is_const(size(x,dim)) || ...
%       (isscalar(x) && dim == 2) || ...
%       size(x,dim) ~= 1, ...
%       'EmbeddedMATLAB:libfun:autoDimIncompatibility', ...
%       ['The working dimension was selected automatically, is variably ', ...
%       'sized, and has length 1 at run-time. This is not supported. ', ...
%       'Manually select the working dimension by supplying the DIM argument.']);

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
dim = eml_const(local_const_nonsingleton_dim(x));

%--------------------------------------------------------------------------

function dim = local_const_nonsingleton_dim(x)
eml_allow_enum_inputs;
dim = 2;
for k = eml.unroll(1:eml_ndims(x))
    if ~eml_is_const(size(x,k)) || size(x,k) ~= 1
        dim = k;
        return
    end
end

%--------------------------------------------------------------------------
