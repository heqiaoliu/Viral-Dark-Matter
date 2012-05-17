function obj1 = fft2(obj0)
%FFT2 Two-dimensional discrete Fourier Transform for GPUArray
%   FFT2(X) returns the two-dimensional Fourier transform of 
%   GPUArray X. If X is a vector, the result will have the 
%   same orientation.
%   
%   This operation is only supported for GPUArrays with underlying classes
%   single or double.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 512;
%       D = GPUArray(rand(N));
%       Df = fft2(D)
%   
%   See also FFT2, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $  $Date: 2010/06/10 14:27:50 $

type = classUnderlying(obj0);

if ( ~strcmp('single',type) && ~strcmp('double',type) )
    error( 'parallel:gpu:fft:UnsupportedClass', ...
           'FFT2 is only supported for single and double arrays' );
end

if ( isempty(obj0) )
    if ( isreal(obj0) )
        obj1 = complex(obj0,obj0);
    else
        obj1 = obj0;
    end
else
    
    try
        obj1 = hFft2(obj0);
    catch E
        throw(E)
    end
    
end
     
end


