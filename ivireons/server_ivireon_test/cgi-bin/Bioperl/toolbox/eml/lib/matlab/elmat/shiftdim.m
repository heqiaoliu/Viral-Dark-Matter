function [b,nshifts] = shiftdim(x,n)
%Embedded MATLAB Library Function

%   Copyright 2006-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin >= 1, 'Not enough input arguments.');
if nargin == 1
    if eml_is_const(size(x)) && isscalar(x)
        ns = zeros(eml_index_class);
    else
        dim = eml_const_nonsingleton_dim(x);
        eml_lib_assert(eml_is_const(size(x,dim)) || ...
            isscalar(x) || ...
            size(x,dim) ~= 1, ...
            'EmbeddedMATLAB:shiftdim:autoDimIncompatibility', ...
            ['The number of shifts was selected automatically, but ', ...
            'the leading dimension of the output is variably sized ', ...
            'and has length 1 at run-time. The second input ', ...
            'argument, n, is required for this usage.']);
        ns = eml_index_minus(dim,1);
    end
    negn = false;
else
    eml_assert(~eml.isenum(n), 'Enumerations not supported for second input argument.');
    eml_assert(eml_is_const(n), 'Second argument must be a constant.');
    eml_lib_assert(isempty(n) || (isa(n,'numeric') && isscalar(n) && ...
        isreal(n) && eml_scalar_floor(n) == n), ...
        'EmbeddedMATLAB:shiftdim:invalidNshifts', ...
        'Second argument must be empty or a real, integer scalar.');
    if (eml_is_const(isempty(n)) && isempty(n)) || n == 0
        ns = zeros(eml_index_class);
        negn = false;
    elseif n > 0
        eml_lib_assert(ndims(x) == eml_ndims(x) || ...
            eml_index_plus(n,1) == eml_const_nonsingleton_dim(x), ...
            'EmbeddedMATLAB:shiftdim:wrongNDims', ...
            ['The first input argument must always have the same ', ...
            'number of dimensions when the number of shifts is ', ...
            'supplied and is positive.']);
        ns = rem(cast(n,eml_index_class),eml_ndims(x));
        negn = false;
    else
        ns = cast(eml_scalar_abs(n),eml_index_class);
        negn = true;
    end
end
if ns == 0
    b = x;
    nshifts = 0;
elseif negn
    b = reshape(x,[ones(1,ns,eml_index_class),size(x)]);
    nshifts = -double(ns);
else
    b = permute(x,[eml_index_plus(ns,1):eml_ndims(x),1:ns]);
    nshifts = double(ns);
end
