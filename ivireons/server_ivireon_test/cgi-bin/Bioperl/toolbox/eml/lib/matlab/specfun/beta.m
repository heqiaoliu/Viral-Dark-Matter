function y = beta(z,w)
%Embedded MATLAB Library Function

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml 

eml_assert(nargin == 2, 'Not enough input arguments.');
y = exp(gammaln(z)+gammaln(w)-gammaln(z+w));
