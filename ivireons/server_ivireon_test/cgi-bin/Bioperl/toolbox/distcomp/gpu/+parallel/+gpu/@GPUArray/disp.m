function disp( obj )
%DISP Display GPUArray
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       disp(D);
%   
%   See also DISP, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/DISPLAY.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:10 $

fprintf( 1, 'parallel.gpu.GPUArray:\n' );
fprintf( 1, '---------------------\n' );
if ~hIsValid( obj )
    disp( 'Data no longer exists on the GPU.' );
    if ~isequal( get( 0, 'FormatSpacing' ), 'compact' )
        disp( ' ' );
    end
else
    if isreal( obj )
        cplx = 'real';
    else
        cplx = 'complex';
    end
    dispStruct = struct( 'Size', size( obj ), ....
                         'ClassUnderlying', classUnderlying( obj ), ...
                         'Complexity', cplx );
    disp( dispStruct );
end

end
