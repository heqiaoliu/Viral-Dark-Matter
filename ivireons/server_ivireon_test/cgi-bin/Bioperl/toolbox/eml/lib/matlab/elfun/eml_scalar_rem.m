function r = eml_scalar_rem(x,y)
%Embedded MATLAB Library Function

%   Note:  All arithmetic is performed in the output class.  This may lead
%   to different rounding errors compared to MATLAB's REM function.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

if ~eml_option('DesignVerifier') && isa(x,class(y)) && isa(x,'numeric')
    r = eml_rem(x,y);
else
    r = eml.nullcopy(eml_scalar_eg(x,y));
    if isinteger(x) || isinteger(y)
        if y == 0
            r = eml_scalar_eg(x,y);
        else
            r = eml_minus(x,eml_times(y,eml_rdivide(x,y, ...
                                                    class(r),'wrap','to zero'), ...
                                      class(r),'wrap'), ...
                          class(r),'wrap');
        end
    elseif y == eml_scalar_floor(y)
        r = x - eml_scalar_fix(eml_rdivide(x,y)).*y;
    else
        r = eml_rdivide(x,y);
        % Check for nearly integer quotient.
        if eml_scalar_abs(r - eml_scalar_round(r)) <= ...
                eps(class(r))*eml_scalar_abs(r)     
            r = zeros(class(r));
        else
            r = (r - eml_scalar_fix(r)).*y;
        end
    end
end
