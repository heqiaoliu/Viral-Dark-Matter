function y = isdouble(x)
% Embedded MATLAB Library function.

%ISDOUBLE  is not defined for any input argument of non-fi object.
%   ISDOUBLE(X) errors out if the input argument is non-fi object.
%

% Copyright 2002-2008 The MathWorks, Inc.
%#eml
% $Revision: 

eml_assert(eml_ambiguous_types,['Function ''isdouble'' is not defined for a first argument of class ', class(x), '.']);
y = logical(0);
