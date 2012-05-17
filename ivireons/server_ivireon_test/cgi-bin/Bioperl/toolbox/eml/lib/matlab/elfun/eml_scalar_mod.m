function r = eml_scalar_mod(x,y)
%Embedded MATLAB Library Function

%   Note:  All arithmetic is performed in the output class.  This may lead
%   to different rounding errors compared to MATLAB's MOD function.

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

r = eml.nullcopy(eml_scalar_eg(x,y));
if y == 0
    r = cast(x,class(r));
elseif isinteger(r)
    t = eml_rdivide(x,y,class(r),'wrap','floor');
    t = eml_times(t,y,class(r),'wrap');
    r = eml_minus(x,t,class(r),'wrap');
    % Note that the computation of t really does wrap in cases such as
    % mod(intmin,3).  To avoid wrapping of intermediate results, we
    % could use 'to zero' rounding followed by:
    % if (r < 0) ~= (y < 0)
    %     r = eml_plus(r,y,class(r),'wrap');
    % end
elseif y == eml_scalar_floor(y)
    r = x - eml_scalar_floor(eml_rdivide(x,y)).*y;
else
    r = eml_rdivide(x,y);
    % Check for nearly integer quotient.
    if eml_scalar_abs(r - eml_scalar_round(r)) <= ...
            eps(class(r))*eml_scalar_abs(r)
        r = zeros(class(r));
    else
        r = (r - eml_scalar_floor(r)).*y;
    end
end

