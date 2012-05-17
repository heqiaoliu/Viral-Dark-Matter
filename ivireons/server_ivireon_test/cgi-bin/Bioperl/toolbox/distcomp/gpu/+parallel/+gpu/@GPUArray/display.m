function display( obj )
%DISPLAY Display GPUArray
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       display(D);
%   
%   See also DISPLAY, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/DISP.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:11 $

if isequal( get( 0, 'FormatSpacing' ), 'compact' )
    s = '';
else
    s = sprintf( '\n' );
end

name = inputname(1);
if isempty( name )
    name = 'ans';
end

fprintf( 1, '%s%s =%s\n', ...
         s, name, s );
disp( obj );

end
