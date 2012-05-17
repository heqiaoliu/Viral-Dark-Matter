classdef MotionJpegAVI < audiovideo.writer.profile.IProfile
    %UncompressedAVI Write uncompressed AVI files.
    
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.2 $ $Date: 2010/05/10 17:22:55 $
    
    properties (SetAccess=protected)
        % Properties inherited from IProfile
        
        Name = 'Motion Jpeg AVI';
        Description = 'An AVI file with Motion JPEG compression';
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
        
        function prof = MotionJpegAVI(fileName)
            if nargin == 0
                fileName = '';
            end
            
            prof = prof@audiovideo.writer.profile.IProfile();
            prof.Plugin = audiovideo.internal.writer.plugin.MotionJpegAviFilePlugin(fileName);
            prof.VideoProperties = audiovideo.writer.properties.MotionJpegVideoProperties(...
                prof.Plugin.ColorFormat, ...
                prof.Plugin.ColorChannels, ...
                prof.Plugin.BitsPerPixel, ...
                75);
        end
        
        function open(obj)
            % OPEN Open the object for writing.
            
            obj.VideoProperties.open();
            obj.Plugin.open(obj.VideoProperties.FrameRate, obj.VideoProperties.Quality);
        end
        
        function close(obj)
            % CLOSE Close the object and finalize the file.
            
            obj.Plugin.close();
            obj.VideoProperties.close();
        end
        
    end
end

