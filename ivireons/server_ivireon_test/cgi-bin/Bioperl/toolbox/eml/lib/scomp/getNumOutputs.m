function N = getNumOutputs(obj)
%Embedded MATLAB Library function.
% Implement getNumOutputs function for System objects.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/05 22:15:51 $
%#eml

eml_allow_mx_inputs;
eml_must_inline;

obj = obj;  %#ok<ASGSL> % To have this variable exist in debug mode;

if isa(obj, 'function_handle')
    N = obj('getNumOutputs');
    return;
end

eml_assert(eml_const(isa(eml_sea_get_obj(obj), 'matlab.system.SFunCore')), ...
           'getNumOutputs method is not supported for this object.');
N = eml_const(feval('getNumOutputs', eml_sea_get_obj(obj)));
