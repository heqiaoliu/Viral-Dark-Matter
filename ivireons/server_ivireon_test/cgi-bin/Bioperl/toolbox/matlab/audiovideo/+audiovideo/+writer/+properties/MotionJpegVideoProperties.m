classdef MotionJpegVideoProperties < audiovideo.writer.properties.VideoProperties
   %VideoProperties Default set of properties for an mmwriter profile.
   %   The VideoProperties class provides a default set of properties for
   %   an mmwriter profile.  It contains the minimum set of properties
   %   that a profile must expose, as well as default values for those
   %   properties.  Profiles will generally use an extended version of the
   %   VideoProperties class in order to add properties specific to that
   %   profile.
   %    
   %   VideoProperties objects are created automatically by the mmwriter
   %   class.  User will normally not need to create a VideoProperties
   %   object explicitly.
   %
   %   VideoProperties properties:
   %     BitsPerPixel - Bits per pixel of the output video data
   %     ColorFormat - Color format of the output video data
   %     ColorChannels - Number of color channels in each video frame
   %     Compression - Video Compression Type
   %     Height - Height of the video being created
   %     Width - Width of the video being created
   %     FramesWritten - The total number of frames written to the file
   %     FrameRate - Frame rate in frames per second
   %
   %   See also mmwriter, audiovideo.writer.profile.IProfile.
   %   Copyright 2009-2010 The MathWorks, Inc.
   %   $Revision: 1.1.6.2 $  $Date: 2010/05/10 17:22:57 $
    
    properties (Access=public)
        % Motion JPEG specific properties
        Quality = 100 % Quality of Compressed Video
    end
    
    methods(Access=public)
        function obj = MotionJpegVideoProperties(colorFormat, colorChannels, bitsPerPixel, quality)
            obj@audiovideo.writer.properties.VideoProperties(colorFormat, colorChannels, bitsPerPixel);
            obj.Quality = quality;
            obj.VideoCompressionMethod = 'Motion JPEG';
        end
    end
    
     % Property getters and setters
    methods
        function set.Quality(obj,value)
            obj.errorIfOpen('Quality');
            validateattributes(value, {'numeric'}, ...
                {'integer', 'finite', 'scalar' ...
                 '>=', 0, '<=', 100}, ...
                'set', 'Quality');
            obj.Quality = value;
        end
    end
    
end

