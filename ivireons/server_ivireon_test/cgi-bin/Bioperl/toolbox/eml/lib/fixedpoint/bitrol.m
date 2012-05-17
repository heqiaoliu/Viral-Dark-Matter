function w = bitrol(u, v)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:41:22 $

if eml_ambiguous_types
    if isscalar(u)
        w = eml_not_const(reshape(zeros(size(v)),size(v)));
    else
        w = eml_not_const(reshape(zeros(size(u)),size(u)));
    end
    return;
end

eml_assert(false,['Function ''bitrol'' is not defined for a first argument of class ',class(u) '.']);

w = 0;

