function tf = pIsSupportedForElementwise( obj )
% Return true if and only if element-wise operations are supported for
% class or classUnderlying of obj.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/21 17:56:45 $

if isa(obj, 'parallel.gpu.GPUArray')
    clz = classUnderlying(obj);
else
    clz = class(obj);
end
supportedDataTypes = {'single', 'double', 'int32', 'uint32', 'logical'};
tf = any(strcmp(clz, supportedDataTypes));
end
