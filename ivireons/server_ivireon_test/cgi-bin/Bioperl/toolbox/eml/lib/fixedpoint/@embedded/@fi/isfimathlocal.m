function b = isfimathlocal(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:54:02 $

eml_assert(nargin==1,'Incorrect number of input arguments.');    
if eml_ambiguous_types
    b = eml_not_const(true);
    return;
end

b = eml_fimathislocal(x);
