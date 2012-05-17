function [a,b,c,s] = eml_blas_xrotg(a,b)
%Embedded MATLAB Private Function

%   Level 1 BLAS xROTG(A,B,C,S)

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas
    [a,b,c,s] = eml_refblas_xrotg(a,b);
else
    % Select BLAS function.
    if isreal(a)
        if isa(a,'single')
            fun = 'srotg32';
        else
            fun = 'drotg32';
        end
    else
        if isa(a,'single')
            fun = 'crotg32';
        else
            fun = 'zrotg32';
        end
    end
    % Declare C and S.
    c = zeros(class(a)); % C is always real.
    s = eml_scalar_eg(a); % S may be complex.
    % Call the BLAS function.
    eml.ceval(fun,eml.ref(a),eml.ref(b),eml.ref(c),eml.ref(s));
end
