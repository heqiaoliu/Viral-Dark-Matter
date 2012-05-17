function b = isfimathlocal(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:53:22 $

eml_assert(nargin==1,'Incorrect number of input arguments.');    
if eml_ambiguous_types
    b = eml_not_const(true);
    return;
end

eml_assert(false,['Function ''isfimathlocal'' is not defined for a first argument of class ',class(x) '.']);

b = 0;

