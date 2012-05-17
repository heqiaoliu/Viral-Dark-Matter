function p = eml_safe_eq(a,b)
%Embedded MATLAB Private Function

%   Performs "safe" equality comparisons of floats.  Determines whether
%   abs(b - a) < eps(b/2).  If one argument is constant, it is better to
%   make it the second argument.  When neither input is floating point,
%   p = (a == b).

%   Copyright 2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_must_inline;
if isreal(a) && isreal(b)
    if isa(a,'float') && isa(b,'float')
        if isa(a,class(b))
            p = abs(b - a) < eps(b/2) || ...
                (isinf(a) && isinf(b) && (a > 0) == (b > 0));
        else
            p = eml_safe_eq(double(a),double(b));
        end
    elseif isa(a,'float')
        bfloat = cast(b,class(a));
        p = is_exact_float_cast(b,class(a)) && eml_safe_eq(a,bfloat);
    elseif isa(b,'float')
        afloat = cast(a,class(b));
        p = is_exact_float_cast(a,class(b)) && eml_safe_eq(afloat,b);
    else
        p = (a == b);
    end
else
    p = eml_safe_eq(real(a),real(b)) && eml_safe_eq(imag(a),imag(b));
end

%--------------------------------------------------------------------------

function p = is_exact_float_cast(a,fltcls)
% Returns a constant true if cast(a,fltcls) is exact.  Otherwise, it
% generates a range check to return true if the cast is exact, false,
% otherwise.
eml_allow_enum_inputs;
eml_must_inline;
eml_assert(~isa(a,'float'), 'First input must not be a float.');
if eml.isenum(a)
    p = is_exact_float_cast(int32(a),fltcls);
elseif islogical(a) || ischar(a)
    p = true;
elseif isinteger(a)
    nbits = eml_const(eml_int_nbits(class(a)));
    if nbits <= uint8(24)
        p = true;
    elseif nbits <= uint8(53) && strcmp(fltcls,'double')
        p = true;
    elseif strcmp(fltcls,'single') % nbits > 24
        r = eml_const(cast(16777215,class(a))); % pow2(24)-1
        if eml_isa_uint(a)
            p = a <= r;
        else
            p = a >= -r && a <= r;
        end
    else % nbits > 53
        r = eml_const(cast(9007199254740991,class(a))); % pow2(53)-1
        if eml_isa_uint(a)
            p = a <= r;
        else
            p = a >= -r && a <= r;
        end
    end
else
    eml_assert(false, ['Unsupported class: ''',class(a),'''.']);
end

%--------------------------------------------------------------------------
