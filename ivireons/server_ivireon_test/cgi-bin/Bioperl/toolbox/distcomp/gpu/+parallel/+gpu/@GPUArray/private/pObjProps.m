function [isGpu, isNum, isFlt, clzz] = pObjProps( obj )
%pObjProps - return object properties

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:39 $

gpuclzz = 'parallel.gpu.GPUArray';

if isequal( class( obj ), gpuclzz )
    isGpu = true;
    isNum = hIsNumeric( obj );
    isFlt = hIsFloat( obj );
    clzz  = classUnderlying( obj );
else
    isGpu = false;
    isNum = isnumeric( obj );
    isFlt = isfloat( obj );
    clzz  = class( obj );
end
end
