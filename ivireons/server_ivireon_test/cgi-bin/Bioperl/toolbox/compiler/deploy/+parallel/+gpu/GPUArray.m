
%   Copyright 2010 The MathWorks, Inc.

classdef GPUArray %#ok<*STOUT>
    
    methods
        function obj = GPUArray(varargin)
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end        
    end
    
    methods ( Static )
        function [varargout] = colon(varargin) 
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
        function [varargout] = eye(varargin) 
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
        function [varargout] = false(varargin) 
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
        function [varargout] = inf(varargin) 
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
        function [varargout] = nan(varargin) 
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
        function [varargout] = ones(varargin) 
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
        function [varargout] = true(varargin) 
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end
        function [varargout] = zeros(varargin) 
            parallel.gpu.GPUArray.throwDeployedGPUError();
        end        
    end    
    
    methods ( Static, Hidden )
        % This method will be called all public GPU functions when run in
        % deployed mode to indicate that GPU functionality is not
        % supported
        function throwDeployedGPUError()
            err = MException('parallel:gpu:DeploymentNotSupported', ...
                'Deployment of GPU functionality from Parallel Computing Toolbox is not supported.');
            throwAsCaller(err)
        end
    end
end
