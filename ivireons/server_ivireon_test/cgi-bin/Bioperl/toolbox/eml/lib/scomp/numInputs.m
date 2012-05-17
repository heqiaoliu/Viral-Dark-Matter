function N = numInputs(obj)
%Embedded MATLAB Library function.
% Implement numInputs function for System objects.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/29 15:22:06 $
%#eml

eml_allow_mx_inputs;
eml_must_inline;

obj = obj;  %#ok<ASGSL> % To have this variable exist in debug mode;
eml_assert(eml_const(isa(eml_sea_get_obj(obj), 'matlab.system.SFunCore')), ...
           'numInputs method is not supported for this object.');
N = eml_const(feval('numInputs', eml_sea_get_obj(obj)));

