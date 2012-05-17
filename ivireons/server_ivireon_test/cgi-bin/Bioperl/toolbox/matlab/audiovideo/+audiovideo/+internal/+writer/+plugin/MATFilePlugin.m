classdef (Hidden) MATFilePlugin < audiovideo.internal.writer.plugin.IPlugin
    %MATFILEPLUGIN Extension of the IPlugin class to write MAT files.
    %
    %   This is an example of writing an VIDEOWRITER plugin that writes to a
    %   MAT file.  It is based on the asyncio matoutput example and is
    %   not meant for shipping code.
    
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.4 $ $Date: 2010/04/21 21:29:50 $
    
    properties
        ColorFormat = 'RGB24';
        ColorChannels = 3;
        BitsPerPixel = 24;
    end
    
    properties (Access=protected)
        FileName;
    end
    
    methods
        function obj = MATFilePlugin(fileName)
            %MATFilePlugin Construct a MATFilePlugin object.
            %
            %   OBJ = MATFilePlugin(FILENAME) constructs a MATFilePlugin
            %   object pointing to the file specified by FILENAME.  The file
            %   is not created until MATFilePlugin.open() is called.
            %
            %   See also MATFilePlugin/open, MATFilePlugin/close.
            
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
            pluginDir = toolboxdir(fullfile('shared','asynciolib','bin',...
                computer('arch')));
            
            options.LogFileName = obj.FileName;
            obj.Channel = asyncio.Channel(fullfile(pluginDir, 'matoutput'),...
                fullfile(pluginDir, 'matmlconverter'),...
                options, [0,0]);
        end

        function open(obj)
            %OPEN Opens the channel for writing.
            %   MATFilePlugin objects must be open prior to calling
            %   writeVideoFrame.
            
            assert(~isempty(obj.Channel), 'Channel must be set before opening the plugin');
            obj.Channel.open();
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
            
            % Write to MAT file.
            obj.Channel.OutputStream.write(data);
        end
    end
    
end

