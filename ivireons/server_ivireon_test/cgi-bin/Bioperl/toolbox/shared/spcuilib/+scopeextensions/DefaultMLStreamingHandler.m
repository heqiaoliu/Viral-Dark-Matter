classdef DefaultMLStreamingHandler < scopeextensions.AbstractMLStreamingHandler
    %DefaultMLStreamingHandler   Define the DefaultMLStreamingHandler class.

    %   Copyright 2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:43 $

    methods

        function this = DefaultMLStreamingHandler(srcObj, varargin)
            %DefaultMLStreamingHandler   Construct the DefaultMLStreamingHandler class.
            
            this@scopeextensions.AbstractMLStreamingHandler(srcObj);
        end
    end
end

% [EOF]
