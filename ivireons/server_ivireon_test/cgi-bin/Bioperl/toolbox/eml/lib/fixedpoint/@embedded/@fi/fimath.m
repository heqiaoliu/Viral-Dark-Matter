function hf = fimath(var1)
% Embedded MATLAB Library function for fimath the embedded.fi 
%
% $INCLUDE(DOC) toolbox/eml/fixedpoint/fimath.m $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.3 $  $Date: 2009/06/16 03:45:44 $

% FIMATH  Object which encapsulates fixed-point math information.
%     Syntax:

eml_transient;

% This eML library function allows and can handle mxArray inputs
eml_allow_mx_inputs;  

% IF types are ambiguous return a 0
hf =  eml_fimath(var1);




