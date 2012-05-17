function hn = numerictype(var1)
% Embedded MATLAB Library function for numerictype of embedded.fi
%
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.1 $  $Date: 2009/10/24 19:03:32 $

% FIMATH  Object which encapsulates fixed-point math information.
%     Syntax:

eml_transient;

% This eML library function allows and can handle mxArray inputs
eml_allow_mx_inputs;  

% IF types are ambiguous return a 0
hn =  eml_typeof(var1);