function z = expm1(z)
%Embedded MATLAB Library Function

%   Algorithm due to W. Kahan, unpublished course notes.
%   Copyright 1984-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1, 'Not enough input arguments.');
eml_assert(isa(z,'float'), ['Function ''expm1'' is not defined for values of class ''' class(z) '''.']);
for k = 1:eml_numel(z)
    z(k) = eml_scalar_expm1(z(k));
end
