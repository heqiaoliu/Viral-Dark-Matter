function w = bitreplicate(u, N)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.2 $  $Date: 2008/01/15 18:50:36 $

if eml_ambiguous_types
    w = eml_not_const(reshape(zeros(size(u)),size(u)));
    return;
end

eml_assert(false,['Function ''bitreplicate'' is not defined for a first argument of class ',class(u) '.']);

w = 0;
