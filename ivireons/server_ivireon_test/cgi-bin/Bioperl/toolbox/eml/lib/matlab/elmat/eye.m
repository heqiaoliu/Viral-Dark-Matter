function I = eye(n,m,cls)
%Embedded MATLAB Library Function

%   Limitations:
%      Dimensions must be real, non-negative, integer values.

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

switch nargin
    case 0
        I = 1;
    case 1
        if ischar(n)
            I = eye_internal(1,1,n);
        elseif isscalar(n)
            I = eye_internal(n,n,'double');
        else
            eml_lib_assert(eml_numel(n) == 2 && size(n,2) == 2, ...
                'EmbeddedMATLAB:eye:rowVectorMustBeLength2', ...
                'Size vector input must be a row vector of length 2');
            I = eye_internal(n(1),n(2),'double');
        end
    case 2
        if ischar(m)
            if isscalar(n)
                I = eye_internal(n,n,m);
            else
                eml_lib_assert(eml_numel(n) == 2 && size(n,2) == 2, ...
                    'EmbeddedMATLAB:eye:rowVectorMustBeLength2', ...
                    'Size vector input must be a row vector of length 2');
                I = eye_internal(n(1),n(2),m);
            end
        else
            I = eye_internal(n,m,'double');
        end
    case 3
        I = eye_internal(n,m,cls);
    otherwise
        eml_assert(false,'Too many arguments.');
end

%--------------------------------------------------------------------------

function I = eye_internal(n,m,cls)
eml_assert_valid_size_arg(n,m);
eml_assert(eml_is_float_class(cls) || eml_is_integer_class(cls), ...
    'String input must be a valid numeric class name.');
eml_must_inline;
I = zeros(n,m,cls);
q = cast(min(real(n),real(m)),eml_index_class);
if q > 0
    one = ones(cls);
    for i = ones(eml_index_class) : q
        I(i,i) = one;
    end
end

%--------------------------------------------------------------------------

