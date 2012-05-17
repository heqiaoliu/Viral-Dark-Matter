function t = isinf(A)
%ISINF  True for infinite elements
%   Refer to the MATLAB ISINF reference page for more information 
%
%   See also ISINF

%   Copyright 2004-2007 The MathWorks, Inc.
%#eml

% fixed-point and boolean fis can never contain inf.
if isfixed(A) || isboolean(A) || ~eml_option('NonFinitesSupport')
    t = false(size(A));
elseif isreal(A)
    t = eml_isinf(double(A));
else
    t = eml_isinf(real(double(A))) | eml_isinf(imag(double(A)));   
end
