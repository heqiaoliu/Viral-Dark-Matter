function t = isnan(A)
%ISNAN  True for Not-a-Number
%   Refer to the MATLAB ISNAN reference page for more information 
%
%   See also ISNAN

%   Copyright 2004-2007 The MathWorks, Inc.
%#eml

% fixed-point or boolean fis can never contain NaN
if isfixed(A) || isboolean(A) || ~eml_option('NonFinitesSupport')
    t = false(size(A));
elseif isreal(A)
    t = eml_isnan(double(A));
else
    t = eml_isnan(real(double(A))) | eml_isnan(imag(double(A)));
end
