function y = colon(a,b,c)
%Embedded MATLAB Library Function

%   Stub to error on fixedpoint colon inputs.

%   Copyright 2007 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.2 $ $Date: 2007/10/15 22:42:21 $

eml_assert(false, ...
    'COLON is not defined for input arguments of type ''embedded.fi''.');
y = a + b + c; % to make MLINT happy