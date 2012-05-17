classdef (Hidden) MotionJpegAviFilePlugin < audiovideo.internal.writer.plugin.AviFilePlugin
    %AviFilePlugin Extension of the IPlugin class to write uncompressed AVI files.
    
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.1 $ $Date: 2010/04/21 21:29:51 $
    
    properties
        Quality = 65; % JPEG Quality. Valid values are 1 to 100
    end
    
    methods
        function obj = MotionJpegAviFilePlugin(fileName)
            %AviFilePlugin Construct a AviFilePlugin object.
            %
            %   OBJ = AviFilePlugin(FILENAME) constructs a AviFilePlugin
            %   object pointing to the file specified by FILENAME.  The file
            %   is not created until AviFilePlugin.open() is called.
            %
            %   See also AviFilePlugin/open, AviFilePlugin/close.
            
            obj = obj@audiovideo.internal.writer.plugin.AviFilePlugin(fileName);      
        end
        
         
        function open(obj, framerate, quality)
            %OPEN Opens the channel for writing.
            %   AviFilePlugin objects must be open prior to calling
            %   writeVideoFrame.
            
            assert(~isempty(obj.Channel), 'Channel must be set before opening the plugin');
            
            options.FrameRate = framerate;
            options.Quality = quality;
            obj.Channel.open(options);
        end    
        
        function writeVideoFrame(obj, data)
            %writeVideoFrame Write a single video frame to the channel.
            %   obj.writeVideoFrame(data) will write a single video frame
            %   to the channel.  
                       
            % defer to our super class
            writeVideoFrame@audiovideo.internal.writer.plugin.AviFilePlugin(obj, data);
        end
    end
    
    methods(Access=protected)
        function [pluginName, converterName, options] = createChannelOptions(obj)
            %CREATECHANNELOPTIONS 
            %   Override base class to provide custom options.
            pluginName = 'aviplugin';
            converterName = 'mljpegconverter';
            options.OutputFileName = obj.FileName;
            options.Compression = 'MJPG';
        end
    end
end

