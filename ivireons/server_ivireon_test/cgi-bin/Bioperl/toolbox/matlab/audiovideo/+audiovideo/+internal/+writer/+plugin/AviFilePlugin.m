classdef (Hidden) AviFilePlugin < audiovideo.internal.writer.plugin.IPlugin
    %AviFilePlugin Extension of the IPlugin class to write uncompressed AVI files.
    
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.6.2.2.1 $ $Date: 2010/06/21 17:59:08 $
    
    properties
        ColorFormat = 'RGB24';
        ColorChannels = 3;
        BitsPerPixel = 24;
    end
    
    properties(Access=protected)
        FileName;
    end
    
    methods
        function obj = AviFilePlugin(fileName)
            %AviFilePlugin Construct a AviFilePlugin object.
            %
            %   OBJ = AviFilePlugin(FILENAME) constructs a AviFilePlugin
            %   object pointing to the file specified by FILENAME.  The file
            %   is not created until AviFilePlugin.open() is called.
            %
            %   See also AviFilePlugin/open, AviFilePlugin/close.
            
            obj = obj@audiovideo.internal.writer.plugin.IPlugin();
            
            % Handle the zero argument constructor.  This is needed, for
            % example, when constructing empty profile objects.
            if isempty(fileName)
                obj.Channel = [];
                return;
            end
            
            obj.FileName = fileName;
        end
        
        function set.FileName(obj, value)
            obj.FileName = value;
            
            % After setting the value, create the asyncio Channel object.
            % This is done here instead of in the constructor
            % so that the channel is initialized properly during load and
            % save
            obj.createChannel();
        end
        
        function open(obj, framerate)
            %OPEN Opens the channel for writing.
            %   AviFilePlugin objects must be open prior to calling
            %   writeVideoFrame.
            
            assert(~isempty(obj.Channel), 'Channel must be set before opening the plugin');
            
            options.FrameRate = framerate;
            obj.Channel.open(options);
        end
        
        function close(obj)
            % CLOSE Closes the channel for writing.
            %   It is an error to call writeVideoFrame after calling
            %   close().
            
            if isempty(obj.Channel)
                return;
            end
            
            % Finish sending data.
            obj.Channel.OutputStream.flush(true);
            obj.Channel.close();
        end
        
        function writeVideoFrame(obj, data)
            %writeVideoFrame Write a single video frame to the channel.
            %   obj.writeVideoFrame(data) will write a single video frame
            %   to the channel.  Since the MATFilePlugin isn't actually a
            %   video plugin, MATFilePlugin/writeVideoFrame will accept any
            %   data in any format, which is useful for testing.
            
            assert(~isempty(obj.Channel), 'Channel must be set before writing to the plugin');
            assert(obj.Channel.isOpen(), 'Channel must be open before writing data.');
            assert(isnumeric(data),'Data to write must be numeric');

            obj.Channel.OutputStream.write(data);
        end
    end
    
    methods(Access=protected)
        
        function [pluginName, converterName, options] = createChannelOptions(obj)
            %CREATECHANNELOPTIONS options for asyncio channel creation
            %   Setup options used in createChannel function.
            %   Subclasses can override this function to provide custom
            %   plugins and options
            pluginName = 'aviplugin';
            converterName = 'mlpackedrgbconverter';
            options.OutputFileName = obj.FileName;
        end
        
        
        function createChannel(obj)
            %createChannel Create an asyncio Channel object
            pluginDir = fullfile(matlabroot,'toolbox','matlab','audiovideo','bin',...
                'mmwriter', computer('arch'));
            
            % Get plugin names and options
            % Note: createChannelOptions may be overriden by a subclass
            [pluginName, converterName, options] = createChannelOptions(obj);
            
            obj.Channel = asyncio.Channel(fullfile(pluginDir, pluginName),...
                fullfile(pluginDir, converterName),...
                options, [0,0]);
        end
    end
end

