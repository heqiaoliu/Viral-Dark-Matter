function obj1 = ifft2(obj0)
%IFFT2 Two-dimensional inverse discrete Fourier transform.
%   IFFT2(F) returns the two-dimensional inverse Fourier transform of 
%   GPUArray F. If F is a vector, the result will have the 
%   same orientation.
%   
%   This operation is only supported for GPUArrays with underlying classes
%   single or double.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 512;
%       D = GPUArray(rand(N));
%       Df = ifft2(D)
%   
%   See also IFFT2, PARALLEL.GPU.GPUARRAY


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $  $Date: 2010/06/10 14:27:55 $

type = classUnderlying(obj0);

if ( ~strcmp('single',type) && ~strcmp('double',type) )
    error( 'parallel:gpu:fft:UnsupportedClass', ...
           'IFFT2 is only supported for single and double arrays' );
end

if ( isempty(obj0) )
    if ( isreal(obj0) )
        obj1 = complex(obj0,obj0);
    else
        obj1 = obj0;
    end
else
    
    try
        obj1 = hiFft2(obj0);
    catch E
        throw(E)
    end
    
    sz = size(obj1);
    obj1 = hInPlaceScale(obj1,parallel.gpu.GPUArray(sz(1).*sz(2)));

end

end
