classdef VideoMLStreamingHandler < scopeextensions.AbstractMLStreamingHandler
    %VIDEOMLSTREAMINGHANDLER Define the VideoMLStreamingHandler class.

    %   Copyright 2007-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.12 $  $Date: 2010/03/31 18:40:48 $

    methods
        function this = VideoMLStreamingHandler(hSource, varargin)
            %VIDEOMLSTREAMINGHANDLER Construct a VIDEOMLSTREAMINGHANDLER object
            %   THIS = VIDEOMLSTREAMINGHANDLER(HSOURCE, DATACONNECTARGS) creates a data
            %   handler for a MATLAB streaming source HSOURCE with a video visual.
            %   DATACONNECTARGS are the data connection arguments passed as a cell
            %   array (DataConnectArgs property of the SrcMLStreaming object) and are
            %   used to specify the FrameData, and FrameRate properties of the contained
            %   VideoData object.

            this@scopeextensions.AbstractMLStreamingHandler(hSource);
        end
        
        function str = getTimeStatusString(this)
          hSource = this.Source;
          str = sprintf('%g', hSource.FrameCount);
        end
        
        function str = getStatusControlTooltip(~, control)
          switch control
            case 'Frame'
              str = sprintf('Frame Number');
          end
        end
        
        
        function msg = emptyFrameMsg(this) %#ok
            %EMPTYFRAMEMSG Text message indicating empty video frame size
            %   For streaming video data we return no text and leave a blank display.

            msg = {'Video frame contains no data', ...
                '(size is 0x0)'};
        end
    end
end

% [EOF]
