function y = isscaleddouble(x)
% Embedded MATLAB Library function.

%ISSCALEDDOUBLE is not defined for any input argument of non-fi object.
%   ISSCALEDDOUBLE(X) errors out if the input argument is non-fi object.
%

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.3 $  $Date: 2008/11/13 17:53:26 $


eml_assert(eml_ambiguous_types,['Function ''isscaleddouble'' is not defined for a first argument of class ', class(x), '.']);
y = logical(0);

