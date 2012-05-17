classdef HistogramMLStreamingHandler < scopeextensions.AbstractMLStreamingHandler
    % Class definition of the HistogramMLStreamingHandler

    %   Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.3 $    $Date: 2010/03/31 18:40:44 $
        
    methods
        function this = HistogramMLStreamingHandler(hSource, varargin)
            this@scopeextensions.AbstractMLStreamingHandler(hSource);
        end
        
        function msg = emptyFrameMsg(this) %#ok
            % Text message indicating unavailable data
            msg = {'There is no data available in the present frame'};
        end
    end
end

% [EOF]
