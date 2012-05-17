
%   Copyright 2010 The MathWorks, Inc.

classdef CUDAKernel

    methods
        function obj = CUDAKernel(varargin)
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
    end
end