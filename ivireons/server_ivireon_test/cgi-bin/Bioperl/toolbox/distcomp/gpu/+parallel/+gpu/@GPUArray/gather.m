%GATHER Retrieve contents of GPUArray to the CPU
%   X = GATHER(D) is a regular array formed from the contents
%   of the GPUArray D.
%   
%   Example:
%   N = 1000;
%   D = parallel.gpu.GPUArray(magic(N));
%   M = gather(D);
%   
%   retrieves M = magic(N) on the client
%   
%   See also parallel.gpu.GPUArray.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:53 $
