
%   Copyright 2010 The MathWorks, Inc.

classdef GPUDevice %#ok<*STOUT>
    
    methods
        function obj = GPUDevice(varargin)
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
    end
    
    methods ( Static )
        function [varargout] = count(varargin)
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
        function [varargout] = current(varargin)
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
        function [varargout] = getDevice(varargin)
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
        function [varargout] = select(varargin)
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
    end
end