function A = vander(v)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml 

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isnumeric(v), ... % Use ISNUMERIC because fi is OK.
    ['Function ''vander'' is not defined for values of class ''' class(v) '''.']);
eml_lib_assert(isvector(v) || isempty(v), ...
    'EmbeddedMATLAB:vander:argNotVector', ...
    'Argument must be a vector.');
A = eml_vander(v);
