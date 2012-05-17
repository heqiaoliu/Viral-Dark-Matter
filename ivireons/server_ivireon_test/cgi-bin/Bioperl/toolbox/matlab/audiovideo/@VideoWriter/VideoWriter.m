classdef VideoWriter < hgsetget & dynamicprops
    %VideoWriter Create a video writer object.
    %   
    %   OBJ = VideoWriter(FILENAME) constructs a VideoWriter object to
    %   write video data to an AVI file that uses Motion JPEG compression.  
    %   FILENAME is a string enclosed in single quotation marks that specifies 
    %   the name of the file to create. If filename does not include the 
    %   extension '.avi', the VideoWriter constructor appends the extension.
    %
    %   OBJ = VideoWriter( FILENAME, PROFILE ) applies a set of properties
    %   tailored to a specific file format (such as 'Uncompressed AVI') to 
    %   a VideoWriter object. PROFILE is a string enclosed in single 
    %   quotation marks that describes the type of file to create. 
    %   Specifying a profile sets default values for video properties such 
    %   as VideoCompressionMethod. Possible values: 
    %     'Motion JPEG AVI'  - Compressed AVI file using Motion JPEG codec.
    %                          (default)
    %     'Uncompressed AVI' - Uncompressed AVI file with RGB24 video.
    %
    % Methods:
    %   open        - Open file for writing video data. 
    %   close       - Close file after writing video data.
    %   writeVideo  - Write video data to file.
    %   getProfiles - List profiles and file format supported by VideoWriter. 
    %
    % Properties:
    %   ColorChannels          - Number of color channels in each output 
    %                            video frame.
    %   Duration               - Scalar value specifying the duration of the 
    %                            file in seconds.
    %   FileFormat             - String specifying the type of file to write.
    %   Filename               - String specifying the name of the file.
    %   FrameRate              - Rate of playback for the video in frames per
    %                            second. After you call open, you cannot 
    %                            change the FrameRate value.
    %   Height                 - Height of each video frame in pixels. 
    %                            The writeVideo method sets values for Height
    %                            and Width based on the dimensions of the 
    %                            first frame.
    %   Path                   - String specifying the fully qualified file
    %                            path.
    %   Quality                - Integer from 0 through 100. Only applies to
    %                            objects associated with the Motion JPEG
    %                            AVI profile. Higher quality numbers result
    %                            in higher video quality and larger file 
    %                            sizes. Lower quality numbers result in 
    %                            lower video quality and smaller file 
    %                            sizes. After you call open, you cannot 
    %                            change the Quality value.
    %   VideoBitsPerPixel      - Number of bits per pixel in each output 
    %                            video frame.
    %   VideoCompressionMethod - String indicating the type of video 
    %                            compression.
    %   VideoFormat            - String indicating the MATLAB representation 
    %                            of the video format.
    %   VideoFrameCount        - Number of frames written to the video file.
    %   Width                  - Width of each video frame in pixels. 
    %                            The writeVideo method sets values for Height
    %                            and Width based on the dimensions of the 
    %                            first frame.
    %
    % Example:
    % 
    %   % Prepare the new file.
    %   vidObj = VideoWriter('peaks.avi');
    %   open(vidObj);
    %
    %   % Create an animation.
    %   Z = peaks; surf(Z);
    %   axis tight
    %   set(gca,'nextplot','replacechildren');
    %
    %   for k = 1:20
    %      surf(sin(2*pi*k/20)*Z,Z)
    %
    %      % Write each frame to the file.
    %      currFrame = getframe;
    %      writeVideo(vidObj,currFrame);
    %   end
    % 
    %   % Close the file.
    %   close(vidObj);
    % 
    % See also VideoWriter/open, VideoWriter/close, 
    %          VideoWriter/writeVideo, VideoWriter/getProfiles.
    
    %   Authors: NH, DT
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 1.1.8.2.2.1 $  $Date: 2010/06/07 13:33:36 $
    
    properties (Dependent, Transient, SetAccess=private)
        Duration = 0; %The total duration of the file, in seconds.
    end
    properties(SetAccess=private)
        Filename      %The name of the file to be written.
        Path          %The path to the file to be written.
    end
    
    properties(Dependent, SetAccess=private)
        FileFormat    %The format of the file to be written.
     end
    
    properties(SetAccess=private, Hidden, Transient)
        IsOpen = false; %Indicates if the file is open for writing.
    end
    
    properties(Access=private)
        Profile % The internal profile object.        
        AllowedDataTypes; % The data types that are allowed to be written, cached for performance.
    end
    
    methods
        function obj = VideoWriter(filename, profile)
            
            import audiovideo.internal.writer.profile.ProfileFactory;
            
            if nargin < 1
                error('matlab:VideoWriter:noFile', 'A file name must be specified.');
            elseif nargin < 2
                profile = 'Default';
            elseif nargin == 2
                if ~ischar(profile)
                    error('MATLAB:VideoWriter:invalidProfile', ...
                        'The profile must be specified as a string.');
                end
                
                ProfileFactory.checkIsKnownProfile(profile);
            else
                error(nargchk(1,2, nargin, 'struct'));
            end
            
            if ~ischar(filename)
                error('matlab:VideoWriter:invalidFilename', ...
                    'The file name must be specified as a string.');
            end
            if isempty(filename)
                error('matlab:VideoWriter:emptyFilename', ...
                    'The file name must not be empty.');
            end
                        
            % Many MATLAB functions assume that any slashes in a file name
            % are really the filesep for the current platform.
            filename = regexprep(filename, '[\/\\]', filesep);
            
            [pathstr, baseFile, extProvided ] = fileparts(filename);
            
            % Validate that the directory specified exists.
            if isempty(pathstr)
                pathstr = pwd;
            end
            
            if ~exist(pathstr, 'dir')
                error('matlab:VideoWriter:folderNotFound', ...
                    'The specified folder, ''%s'', does not exist', pathstr);
            end
            
            
            % Validate that the filename has the correct extension.
            validExtensions = ProfileFactory.getFileExtensions(profile);
            if ~any(strcmp(extProvided, validExtensions))
                extProvided = [extProvided validExtensions{1}];
            end
            
            filename = fullfile(pathstr, [baseFile extProvided]);
            
            % Test that the file can actually be created.
            % Open it in append mode so that any existing file is not
            % destroyed.
            fileExisted = (exist(filename, 'file') ~= 0);
            [fid fidMessage] = fopen(filename, 'a');
            
            if (fid ~= -1)
                % Since the file is write-able and currently exists, use
                % fileattrib to convert the filename into a fully qualified
                % absolute path.
                [~, info] = fileattrib(filename);
                if usejava('jvm')
                    jf = java.io.File(info.Name);
                    filename = char(jf.getCanonicalPath());
                else
                    filename = info.Name;
                end
                fclose(fid);
            end
            
            if (~fileExisted && (fid ~= -1))
                delete(filename);
            end
            
            if (fid == -1)
                error('matlab:VideoWriter:fileNotWritable', ...
                    'Cannot create file %s.  The reason given is:\n\n%s', ...
                filename, fidMessage);
            end
            
            try
                obj.Profile = ProfileFactory.createProfile(profile, filename);
            catch err
                throw(err)
            end
            
            % init file properties
            [pathstr file ext] = fileparts(filename);
            obj.Filename = [file ext];
            obj.Path = pathstr;
            obj.AllowedDataTypes = union(obj.Profile.PreferredDataType, {'single', 'double', 'uint8'});
            
            obj.initDynamicProperties();
        end
        
        function delete(obj)
            %DELETE Delete a VideoWriter object.
            %   DELETE does not need to called directly, as it is called when
            %   the VideoWriter object is cleared.  When DELETE is called, the
            %    object is closed and the file is no longer writable.
            close(obj)
        end
        
        function open(obj)
            %OPEN Open a VideoWriter object for writing.
            %   OPEN(OBJ) must be called before calling the writeVideo
            %   method.  After you call OPEN, all properties of the 
            %   VideoWriter object become read only.
            %
            %   See also VideoWriter/writeVideo, VideoWriter/close.
            
            if length(obj) > 1
                error('matlab:VideoWriter:nonScalar', 'OBJ must be a 1x1 VideoWriter object.');
            end
            
            if obj.IsOpen
                % If open is called multiple times, there should be no
                % effect.
                return;
            end
            try
                obj.Profile.open();
            catch err
                error('matlab:VideoWriter:fileNotWritable', ...
                    'Cannot create file %s.  The reason given is:\n\n%s', ...
                    obj.Filename, err.message);
            end
            obj.IsOpen = true;
        end
        
        function close(obj)
            % CLOSE Finish writing and close video file.
            %
            %   CLOSE(OBJ) closes the file associated with video
            %   writer object OBJ.
            % 
            %   See also VideoWriter/open, VideoWriter/writeVideo.
            
            for ii = 1:length(obj)                
                if ~obj(ii).IsOpen
                    continue;
                end
                
                if obj(ii).FrameCount == 0
                  warning('MATLAB:VideoWriter:noFramesWritten', ...
                  'No video frames were written to this file. The file may be invalid.');
                end

                
                try
                    obj(ii).Profile.close();
                catch err
                    % Don't want to error on close, but don't just swallow
                    % the message.
                    warning(err.identifier, err.message);
                end
                
                obj(ii).IsOpen = false;
            end
        end
        
        function writeVideo(obj,frame)
            % writeVideo write video data to a file
            %
            %   writeVideo(OBJ,FRAME) writes a FRAME to the video file
            %   associated with OBJ.  FRAME is a structure typically 
            %   returned by the GETFRAME function that contains two fields: 
            %   cdata and colormap. If cdata is two-dimensional 
            %   (height-by-width), writeVideo constructs RGB image frames 
            %   using the colormap field. Otherwise, writeVideo ignores the
            %   colormap field. The height and width must be consistent for
            %   all frames within a file.
            %
            %   writeVideo(OBJ,MOV) writes a MATLAB movie MOV to a
            %   video file. MOV is an array of FRAME structures, each of
            %   which contains fields cdata and colormap.
            % 
            %   writeVideo(OBJ,IMAGE) writes data from IMAGE to a
            %   video file.  IMAGE is an array of single, double, or uint8 
            %   values representing grayscale or RGB color images, which 
            %   writeVideo writes as an RGB video frame. For grayscale 
            %   data, image is two-dimensional: height-by-width. 
            %   For color data, image is three-dimensional: 
            %   height-by-width-by-3. The height and width must be 
            %   consistent for all frames within a file. 
            %   Data of type single or double must be in the range [0,1].
            %
            %   writeVideo(OBJ,IMAGES) writes a sequence of color images to
            %   a video file.  IMAGES is a four-dimensional array of 
            %   grayscale (height-by-width-by-1-by-frames) or RGB 
            %   (height-by-width-by-3-by-frames) images.
            %
            %   You must call OPEN(OBJ) before calling writeVideo.            
            %
            %   See also VideoWriter/open, VideoWriter/close.
            
            error(nargchk(2,2, nargin, 'struct'))
            
            if length(obj) > 1
                error('matlab:VideoWriter:nonScalar', 'OBJ must be a 1x1 VideoWriter object.');
            end

            if ~obj.IsOpen
                error('matlab:writeVideo:notOpen', ...
                    'OBJ must be open before writing video.  Call open(obj) before calling writeVideo.');
            end
            
            if (obj.FrameCount > 0)
                [frameHeight, frameWidth] = VideoWriter.getFrameSize(frame);
                if ( (frameHeight ~= obj.Height) || ...
                    (frameWidth ~= obj.Width) )
                    error('matlab:writeVideo:invalidDimensions', ...
                        'Frame must be %d by %d', obj.Width, ...
                        obj.Height);
                end
            end
            try
                if isstruct(frame)
                    obj.writeStructFrames(frame);
                else
                    obj.writeImageFrames(frame);
                end
            catch err
                throw(err)
            end
        end
        
        function value = get.Duration(obj)
            value = obj.FrameCount * 1/obj.FrameRate;
        end
        
        function set.Duration(~, ~)
            error('matlab:VideoWriter:setDuration', 'The value of the Duration property is read-only');
        end
        
        function value = get.FileFormat(obj)
            value = obj.Profile.FileFormat;
        end
        
        function set.FileFormat(~, ~)
            error('matlab:VideoWriter:setFileFormat', 'The value of the FileFormat property is read-only');
        end
    end
    
    methods (Hidden)
        
        function getdisp(obj)
            if (length(obj) > 1)
                getdisp@hgsetget(obj);
                return;
            end
            
            fprintf(audiovideo.internal.writer.DisplayFormatter.getDisplayHeader(obj));
            
            fprintf('  General Properties:\n');
            fprintf(audiovideo.internal.writer.DisplayFormatter.getPropertiesString(obj, ...
                {'Filename', 'Path', 'FileFormat', 'Duration'}, ''));
            
            fprintf('\n  Video Properties:\n');
            fprintf(obj.Profile.VideoProperties.getPropDispString(''));
            fprintf('\n');
            
            fprintf(audiovideo.internal.writer.DisplayFormatter.getDisplayFooter(obj));
        end
        
        function disp(obj)
            if (length(obj) > 1)
                disp@hgsetget(obj);
                return;
            end
            obj.getdisp()
        end
        
        function display(obj)            
            obj.disp();
        end
        function c = horzcat(varargin)
            %HORZCAT Horizontal concatenation of VideoWriter objects.
            %   Horizontal concatenation of VideoWriter objects is not
            %   allowed.
            %
            %    See also VideoWriter/vertcat, VideoWriter/cat.
            
            if (nargin == 1)
                c = varargin{1};
            else
                error('MATLAB:VideoWriter:nocatenation',...
                    'VideoWriter objects cannot be concatenated.');
            end
        end
        function c = vertcat(varargin)
            %VERTCAT Vertical concatenation of VideoWriter objects.
            %
            %   Vertical concatenation of VideoWriter objects is not
            %   allowed.
            %
            %    See also VideoWriter/horzcat, VideoWriter/cat.
            
            if (nargin == 1)
                c = varargin{1};
            else
                error('MATLAB:VideoWriter:nocatenation',...
                    'VideoWriter objects cannot be concatenated.');
            end
        end
        function c = cat(varargin)
            %CAT Concatenation of VideoWriter objects.
            %
            %   Concatenation of VideoWriter objects is not allowed.
            %
            %    See also VideoWriter/horzcat, VideoWriter/vertcat.
            if (nargin > 2)
                error('MATLAB:VideoWriter:nocatenation',...
                    'VideoWriter objects cannot be concatenated.');
            else
                c = varargin{2};
            end
        end

        % Hidden methods from the hgsetget super class.
        function res = eq(obj, varargin)
            res = eq@hgsetget(obj, varargin{:});
        end
        function res =  fieldnames(obj, varargin)
            res = fieldnames@hgsetget(obj,varargin{:});
        end
        function res = ge(obj, varargin)
            res = ge@hgsetget(obj, varargin{:});
        end
        function res = gt(obj, varargin)
            res = gt@hgsetget(obj, varargin{:});
        end
        function res = le(obj, varargin)
            res = le@hgsetget(obj, varargin{:});
        end
        function res = lt(obj, varargin)
            res = lt@hgsetget(obj, varargin{:});
        end
        function res = ne(obj, varargin)
            res = ne@hgsetget(obj, varargin{:});
        end
        function res = findobj(obj, varargin)
            res = findobj@hgsetget(obj, varargin{:});
        end
        function res = findprop(obj, varargin)
            res = findprop@hgsetget(obj, varargin{:});
        end
        function res = addlistener(obj, varargin)
            res = addlistener@hgsetget(obj, varargin{:});
        end
        function res = notify(obj, varargin)
            res = notify@hgsetget(obj, varargin{:});
        end
        function res = setdisp(obj, varargin)
            res = setdisp@hgsetget(obj, varargin{:});
        end
        
        % Hidden methods from the dynamic proper superclass
        function res = addprop(obj, varargin)
            res = addprop@dynamicprops(obj, varargin{:});
        end
        
    end
    methods (Access=private)
        function initDynamicProperties( obj )
            % Create dynamic properties from our Profile.VideoProperties
            % object
            vidPropsMeta = metaclass(obj.Profile.VideoProperties);        
            cellfun(@obj.addDynamicProp, vidPropsMeta.Properties); 
        end
        
        function addDynamicProp(obj, metaprop)
           % Add given a meta-property, expose the property as a dependent
           % property in this class with custom get/set methods where 
           % appropriate. 

           if ~strcmpi(metaprop.GetAccess,'public')
               return;
           end
           
           prop = addprop(obj, metaprop.Name);
           prop.Dependent = true;
           prop.Transient = true;
           prop.GetMethod = @(obj) obj.Profile.VideoProperties.(metaprop.Name);
           
           if strcmpi(metaprop.SetAccess,'public')
                prop.SetMethod = @(obj, value) obj.setDynamicProp(metaprop.Name, value);
           else
                prop.SetAccess = 'private';
           end
        end
        
        function setDynamicProp(obj, propertyName, value)
           obj.Profile.VideoProperties.(propertyName) = value;
        end
        
        function writeImageFrames(obj, frames)
            % Write image frames to the file.
            
            % Figure out the allowed data types for the profile and
            % determine if the supplied image is of an allowable type.
            dataType = class(frames);
            
            if ~any(strmatch(dataType, obj.AllowedDataTypes))
                allTypes = sprintf('%s, ', obj.AllowedDataTypes{:});
                allTypes = allTypes(1:end-2);
                error('matlab:writeVideo:dataType', ...
                    'IMG must be of one of the following classes: %s', allTypes);
            end
            
            frames = obj.convertColorspace(frames);
            
            % Convert the data type to the profile's preferred data type.
            frames = obj.convertDataType(frames);
            
            numFrames = size(frames, 4);
            for ii = 1:numFrames
                obj.Profile.writeVideoFrame(frames(:,:,:,ii));
            end
        end
        
        function writeStructFrames(obj, frames)
            % Write data in struct format by converting the frames to an
            % image representation.
            
            frames = obj.convertColorspace(frames);
            obj.writeImageFrames(frames);
        end
        
        function frames = convertColorspace(obj, frames)
            % Convert the frames to the correct color space.  This also
            % converts them to the right format for looping.
            if strmatch('rgb', lower(obj.VideoFormat))
                frames = obj.convertFramesToRGB(frames);
            elseif strmatch('grayscale', lower(obj.VideoFormat))
                frames = obj.convertFramesToMono(frames);
            else
                assert(false, 'Unknown ColorFormat for this profile.')
            end
        end
        
        function outFrames = convertDataType(obj, frames)
            % Convert the frames to the correct data type.  Frames that are
            % doubles or singles must be in the range [0, 1].  Frames that
            % are of an integer type smaller than that requested by the
            % profile are upconverted.
            
            curDataType = class(frames);
            prefDataType = obj.Profile.PreferredDataType;
            
            % No conversion case.
            if isequal(curDataType, prefDataType)
                outFrames = frames;
                return;
            end
            
            % Validate range for floating point data.
            if any(strmatch(curDataType, {'single', 'double'}))
                if (min(frames(:)) < 0) || (max(frames(:)) > 1)
                    error('matlab:writeVideo:invalidRange', ...
                        'Frames of type %s must be in the range 0 to 1.', curDataType);
                end
            end
            
            if any(strmatch(curDataType, {'single', 'double'}))
                % Convert single and double frames into the appropriate data
                % type.
                minval = double(intmin(prefDataType));
                maxval = double(intmax(prefDataType));
                outFrames = cast(frames .* (maxval - minval) - minval, prefDataType);
                return
            end

            % Otherwise we need to convert from uint8 to some other type.
            shift = log2((double(intmax(prefDataType)) - double(intmin(prefDataType)) + 1) ...
                /(double(intmax(curDataType)) - double(intmin(curDataType)) + 1));
            outFrames = bitshift(cast(frames, prefDataType), shift);
        end
    end
    
    methods(Static)
        function profiles = getProfiles()
            %getProfiles List profiles supported by VideoWriter.
            %
            %  PROFILES = VideoWriter.getProfiles() returns an array of 
            %  audiovideo.writer.ProfileInfo objects that indicate the 
            %  types of files VideoWriter can create.
            % 
            %  audiovideo.writer.ProfileInfo objects contain the following
            %  read-only properties:
            %    Name                   - Name of the profile 
            %    Description            - Description of the intent of 
            %                             the profile.
            %    FileExtensions         - Cell array of strings containing
            %                             file extensions supported by the
            %                             file format.
            %    VideoCompressionMethod - String indicating the type of
            %                             video compression.
            %    VideoFormat            - String indicating the MATLAB
            %                             representation of the video 
            %                             format.
            %    VideoBitsPerPixel      - Number of bits per pixel in each
            %                             output video frame.
            %    Quality                - Number from 0 through 100. Higher
            %                             values correspond to higher 
            %                             quality video and larger files. 
            %                             Only applies to objects 
            %                             associated with the Motion 
            %                             JPEG AVI profile.
            %    FrameRate              - Rate of playback for the video in
            %                             frames per second. 
            %    ColorChannels          - Number of color channels in each 
            %                             output video frame.
            %
            % See also VideoWriter
            
            import audiovideo.internal.writer.profile.ProfileFactory;
            
            profiles = ProfileFactory.getKnownProfileInfos();
        end
        
    end
    
    methods(Static, Hidden)
        %------------------------------------------------------------------
        % Persistence
        %------------------------------------------------------------------        
        function obj = loadobj(obj)
            % Object is already created, initialize any dynamic properties.
            % All of VideoWriter's Dynamic properties are transient and
            % need to be initialized during construction and load.
            obj.initDynamicProperties();
        end
    end
    
    methods(Static, Access=private)
        function outFrames = convertFramesToRGB(frames)
            % Convert frames into an HxWx3xF representation assumed to be
            % the RGB color space.
            
            % Are the frames an array?            
            if ~isstruct(frames)
                
                if (ndims(frames) > 4)
                    error('matlab:writeVideo:badBands', ...
                        'IMG must be an array of either grayscale or RGB images.');
                end
                
                % Need to get all four dimensions so that they're not all
                % collapsed into the last dimension.
                [~, ~, bands, ~] = size(frames);
                
                % If the data is an array, it must be either three banded
                % or single banded.  Three banded data is assumed to be
                % RGB.  Single banded data is converted to RGB by
                % replicating the data for each band.
                if (bands == 3)
                    outFrames = frames;
                    return;
                elseif (bands == 1)
                    outFrames = repmat(frames, [1 1 3 1]);
                    return
                else
                    error('matlab:writeVideo:badBands', ...
                        'IMG must be an array of either grayscale or RGB images.');
                end
            else
                % Data passed in was a struct.
                
                fields = fieldnames(frames);
                
                % Structs must have only cdata and colormap fields.
                if ~isequal({'cdata'; 'colormap'}, sort(fields(:)))
                    error('matlab:writeVideo:badStruct', ...
                        'FRAME must have the fields ''cdata'' and ''colormap''.');
                end

                % Verify that the cdata is actually provided.
                dataPresent = arrayfun(@(x) ~isempty(x.cdata), frames);
                
                if ~all(dataPresent) 
                    error('matlab:writeVideo:noCData', 'The ''cdata'' field of FRAME must not be empty');
                end
                
                % Verify that the sizes of the images are all the same.
                sizes = arrayfun(@(x) size(x.cdata), frames, 'UniformOutput', false);
                
                if (length(sizes) > 1) && ~isequal(sizes{:})
                    error('matlab:writeVideo:cdataSize', ...
                        'All ''cdata'' fields in FRAMES must be the same size.');
                end
                
                hasColormap = arrayfun(@(x) ~isempty(x.colormap), frames);
                
                if any(hasColormap) && ~all(hasColormap)
                    error('matlab:writeVideo:allColormap', ...
                        'The frames provided to a single call of writeVideo must either all have a colormap or all lack a colormap.');
                end
                    
                if all(hasColormap)
                    
                    % Data here should be HxW or HxWx1 only 
                    if ((length(sizes{1}) ~= 2) && sizes{1}(3) ~= 1)
                        error('matlab:writeVideo:badCData', ...
                            'All ''cdata'' fields with a specified ''colormap'' must be two dimensional.');
                    end
                                        
                    outFrames = zeros([sizes{1}, 3, length(frames)]);                
                    for ii = 1:length(frames)
                        try
                            outFrames(:,:,:,ii) = ind2rgb(frames(ii).cdata, frames(ii).colormap);
                        catch err
                            error('matlab:writeVideo:invalidind2rgb', ...
                                'Unable to convert a frame into an RGB image.');
                        end
                    end
                else
                    % Make sure that all of the cdata elements have the
                    % same data type.
                    dataTypes = arrayfun(@(x) class(x.cdata), frames, 'UniformOutput', false);
                    if ~all(strcmp(dataTypes{1}, dataTypes))
                        error('matlab:writeVideo:inconsistentDataTypes', ...
                            'All cdata fields of MOV must have the same data type if cdata contains a truecolor image.');
                    end
                    
                    % Make sure that all of the cdata fields are three
                    % banded.
                    if (numel(sizes{1}) ~= 3)
                        error('matlab:writeVideo:RGBImageInFrame', ...
                            'If the colormap field is empty in a frame, cdata must contain an RGB image.')
                    end
                    outFrames = zeros([sizes{1} length(frames)], class(frames(1).cdata));
                    for ii = 1:length(frames)
                        outFrames(:,:,:,ii) = frames(ii).cdata;
                    end
                end
            end
        end
        
        function outFrames = convertFramesToMono(frames)
            % Convert frames to monochrome.  Currently no colorspace
            % conversion is done, so this function just validates, and if
            % necessary converts, the frames to a HxWx1xF array.
            if ~isstruct(frames)
                if(ndims(frames) > 4)
                    error('matlab:writeVideo:badBands', ...
                        'IMG must be an array of either grayscale or RGB images.');
                end
                
                [m, n, bands, numFrames] = size(frames);
                
                if ( (numFrames ~= 1) && (bands ~= 1) )
                    error('matlab:writeVideo:badBands', ...
                        'IMG must be an array of either grayscale or RGB images.');
                end
                
                outFrames = reshape(frames, [m n 1 max(bands, numFrames)]);
                return;
            else
                error('matlab:writeVideo:framesUnsupported' , ...
                    'The current profile does not support writing frames.');
            end
        end
        
        function [height width] = getFrameSize(frame)
            % Determine the height and width of a frame independent of the
            % input format.
            
            if isstruct(frame)
                [height, width, ~] = size(frame(1).cdata);
            else
                [height, width, ~] = size(frame);
            end
        end
    end
end

