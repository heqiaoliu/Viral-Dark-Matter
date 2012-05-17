function d = isDone(obj)
%Embedded MATLAB Library function.
% Implement isDone function for System objects.

%#eml

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7.4.1 $  $Date: 2010/07/01 18:47:21 $

eml_allow_mx_inputs;
eml_must_inline;

obj = obj;  %#ok<ASGSL> % To have this variable exist in debug mode

if isa(obj, 'function_handle')
    d = obj('isDone');
    return;
end

if eml_const(~isa(obj,'matlab.system.SystemBase'))
       eml_assert(false, 'isDone method is reserved for System objects.');
end 

comp = eml_sea_get_obj(obj);
eml_assert(eml_const(isa(comp, 'matlab.system.SFunCore')), ...
           'isDone method is not supported for this object.');
eml_assert(eml_const(feval('ismember', 'isDone', methods(comp))), ...
           'isDone method can be called only for source System objects.');
N = eml_const(feval('numOutputs', comp));

% Need to generate code only for objects which have eof output
if N > 1 && eml_const(feval('ismember', 'Filename', properties(comp)))
    d = eml_sea_method_call('isDone', obj);
else
    d = false;
end

