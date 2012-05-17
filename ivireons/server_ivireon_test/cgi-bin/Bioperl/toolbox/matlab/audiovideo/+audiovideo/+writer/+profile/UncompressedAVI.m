classdef UncompressedAVI < audiovideo.writer.profile.IProfile
    %UncompressedAVI Write uncompressed AVI files.
    
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.3 $ $Date: 2010/05/10 17:22:56 $
    
    properties (SetAccess=protected)
        % Properties inherited from IProfile
        
        Name = 'Uncompressed AVI';
        Description = 'An AVI file with uncompressed RGB24 video data';
    end

    properties (Constant)
        % Properties inherited from IProfile

        FileExtensions = {'.avi'};
    end
    
    properties (Constant, Hidden)
        % Properties inherited from IProfile

        FileFormat = 'avi';
    end
    
    properties (SetAccess=protected)
        % Properties inherited from IProfile

        VideoProperties
    end
    
    properties(Access=protected)
        % Properties inherited from IProfile

        Plugin
    end
    
    methods
        
        function prof = UncompressedAVI(fileName)
            if nargin == 0
                fileName = '';
            end
            
            prof = prof@audiovideo.writer.profile.IProfile();
            prof.Plugin = audiovideo.internal.writer.plugin.AviFilePlugin(fileName);
            prof.VideoProperties = audiovideo.writer.properties.VideoProperties(...
                prof.Plugin.ColorFormat, ...
                prof.Plugin.ColorChannels, ...
                prof.Plugin.BitsPerPixel);
        end
        
        function open(obj)
            % OPEN Open the object for writing.
            
            obj.VideoProperties.open();
            obj.Plugin.open(obj.VideoProperties.FrameRate);
        end
        
        function close(obj)
            % CLOSE Close the object and finalize the file.
            
            obj.Plugin.close();
            obj.VideoProperties.close();
        end
        
    end
end

