function obj1 = ifft(obj0)
%IFFT Inverse discrete Fourier transform of GPUArray
%   IFFT(X) is the inverse discrete Fourier transform of 
%   GPUArray X.
%   
%   This operation is only supported for GPUArrays with underlying classes
%   single or double.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       Nrow = 2^16;
%       Ncol = 100;
%       D = GPUArray(rand(Nrow, Ncol));
%       F = ifft(D)
%   
%   See also IFFT, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $  $Date: 2010/06/10 14:27:54 $
    
type = classUnderlying(obj0);

if ( ~strcmp('single',type) && ~strcmp('double',type) )
    error( 'parallel:gpu:fft:UnsupportedClass', ...
           'IFFT is only supported for single and double arrays' );
end

if ( isempty(obj0) )
    if ( isreal(obj0) )
        obj1 = complex(obj0,obj0);
    else
        obj1 = obj0;
    end
else
    
    try
        obj1 = hiFft(obj0);
    catch E
        throw(E)
    end
    
    sz = size(obj1);
    
    if isrow(obj1)
        obj1 = hInPlaceScale(obj1,parallel.gpu.GPUArray(sz(2)));
    else
        obj1 = hInPlaceScale(obj1,parallel.gpu.GPUArray(sz(1)));
    end
end

end


