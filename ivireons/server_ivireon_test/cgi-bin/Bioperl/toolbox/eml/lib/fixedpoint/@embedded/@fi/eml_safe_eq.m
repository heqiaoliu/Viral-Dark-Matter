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
    % First convert any fi floats to built-in floats and recurse.  If it
    % dispatches back here after both inputs have been converted, if
    % necessary, then at least one input is fixed.
    if isfi(a) && isfloat(a)
        % Convert A to a built-in float and recurse.
        if issingle(a)
            p = eml_safe_eq(single(a),b);
        else
            p = eml_safe_eq(double(a),b);
        end
    elseif isfi(b) && isfloat(b)
        % Convert B to a built-in float and recurse.
        if issingle(b)
            p = eml_safe_eq(a,single(b));
        else
            p = eml_safe_eq(a,double(b));
        end
    else
        % At least one input is fixed.  It will fail here if the other is a
        % built-in type and not a scalar constant.
        p = (a == b);
    end
else
    p = eml_safe_eq(real(a),real(b)) && eml_safe_eq(imag(a),imag(b));
end
