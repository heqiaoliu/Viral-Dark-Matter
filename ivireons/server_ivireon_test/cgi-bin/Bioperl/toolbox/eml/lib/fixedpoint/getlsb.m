function s = getlsb(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:41:37 $

if eml_ambiguous_types
    s = eml_not_const(reshape(zeros(size(x)),size(x)));
    return;
end

eml_assert(false,['Function ''getlsb'' is not defined for a first argument of class ',class(x) '.']);

s = 0;

