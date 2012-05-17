function obj1 = fft(obj0)
%FFT Discrete Fourier transform of GPUArray
%   Y = FFT(X) is the discrete Fourier transform (DFT) of vector X.  For 
%   matrices, the FFT operation is applied to each column.  For N-D arrays,
%   the FFT operation operates on the first non-singleton dimension.
%   
%   This operation is only supported for GPUArrays with underlying classes
%   single or double.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       Nrow = 2^16;
%       Ncol = 100;
%       D = GPUArray(rand(Nrow, Ncol));
%       F = fft(D)
%   
%   returns the FFT F of the GPUArray matrix by applying the FFT to 
%   each column.
%   
%   
%   See also FFT, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $  $Date: 2010/06/10 14:27:49 $

type = classUnderlying(obj0);

if ( ~strcmp('single',type) && ~strcmp('double',type) )
    error( 'parallel:gpu:fft:UnsupportedClass', ...
           'FFT is only supported for single and double arrays' );
end

if ( isempty(obj0) )
    if ( isreal(obj0) )
        obj1 = complex(obj0,obj0);
    else
        obj1 = obj0;
    end
else
    
    try
        obj1 = hFft(obj0);
    catch E
        throw(E)
    end
    
end

end


