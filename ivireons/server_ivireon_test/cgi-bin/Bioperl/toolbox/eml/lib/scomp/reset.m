function reset(obj)
%Embedded MATLAB Library function.
% Implement reset function for System objects.

%#eml
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/05 22:15:53 $

eml_allow_mx_inputs;
eml_must_inline;

obj = obj;  %#ok<ASGSL> % To have this variable exist in debug mode;

if isa(obj, 'function_handle')
    obj('reset');
    return;
end

if eml_const(~isa(obj,'matlab.system.SystemBase'))
       eml_assert(false, 'reset method is reserved for System objects.');
end 

eml_sea_method_call('reset', obj);

