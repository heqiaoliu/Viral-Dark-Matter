function gpuLocalKernel = pGridLayout(gpuLocalKernel,num)
% helper function to partition the CTAs

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.4.1 $  $Date: 2010/06/21 07:46:54 $

% 256 is 8 warps, i.e. 8*32 which is one warp per processor in a
% Multiprocessor. Also respect MaxThreadsPerBlock for this kernel.
threads = min( 256, gpuLocalKernel.MaxThreadsPerBlock );

totalNumBlocks = ceil( num./threads );
Dx = ceil(sqrt(totalNumBlocks));

gpuLocalKernel.ThreadBlockSize = threads;
gpuLocalKernel.GridSize = [ Dx Dx ];

end


