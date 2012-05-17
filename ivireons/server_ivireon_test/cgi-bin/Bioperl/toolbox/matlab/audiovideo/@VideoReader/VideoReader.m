classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
         VideoReader < hgsetget
% VIDEOREADER Create a multimedia reader object.
%
%   OBJ = VIDEOREADER(FILENAME) constructs a multimedia reader object, OBJ, that
%   can read in video data from a multimedia file.  FILENAME is a string
%   specifying the name of a multimedia file.  There are no restrictions
%   on file extensions.  By default, MATLAB looks for the file FILENAME on
%   the MATLAB path.
%
%   If the object cannot be constructed for any reason (for example, if the
%   file cannot be opened or does not exist, or if the file format is not
%   recognized or supported), then MATLAB throws an error.
%
%   OBJ = VIDEOREADER(FILENAME, 'P1', V1, 'P2', V2, ...) 
%   constructs a multimedia reader object, assigning values V1, V2, etc. to the
%   specified properties P1, P2, etc.
%
%   If an invalid property name or property value is specified, MATLAB throws
%   an error and the object is not created.  Note that the property value pairs
%   can be in any format supported by the SET function, e.g. parameter-value
%   string pairs, structures, or parameter-value cell array pairs.
%
%   Example:
%      % Construct a multimedia reader object associated with file 'xylophone.mpg' with
%      % user tag set to 'myreader1'.
%      readerobj = VideoReader('xylophone.mpg', 'tag', 'myreader1');
%
%      % Read in all video frames.
%      vidFrames = read(readerobj);
%
%      % Get the number of frames.
%      numFrames = get(readerobj, 'numberOfFrames');
%
%      % Create a MATLAB movie struct from the video frames.
%      for k = 1 : numFrames
%            mov(k).cdata = vidFrames(:,:,:,k);
%            mov(k).colormap = [];
%      end
%
%      % Create a figure
%      hf = figure; 
%      
%      % Resize figure based on the video's width and height
%      set(hf, 'position', [150 150 readerobj.Width readerobj.Height])
%
%      % Playback movie once at the video's frame rate
%      movie(hf, mov, 1, readerobj.FrameRate);
%  
%   See also AUDIOVIDEO, VIDEOREADER/GET, VIDEOREADER/SET, VIDEOREADER/READ, MMFILEINFO.                
%

%   Authors: NH DL
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/10 17:23:00 $

    %------------------------------------------------------------------
    % General properties (in alphabetic order)
    %------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Dependent)
        Duration        % Total length of file in seconds.
        Name            % Name of the file to be read.
        Path            % Path of the file to be read.
    end
    
    properties(GetAccess='public', SetAccess='public')
        Tag = '';       % Generic string for the user to set.
    end
    
    properties(GetAccess='public', SetAccess='private', Dependent) 
        Type            % Classname of the object.
    end
    
    properties(GetAccess='public', SetAccess='public')
        UserData        % Generic field for any user-defined data.
    end
    
    %------------------------------------------------------------------
    % Video properties (in alphabetic order)
    %------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Dependent)
        BitsPerPixel    % Bits per pixel of the video data.
        FrameRate       % Frame rate of the video in frames per second.
        Height          % Height of the video frame in pixels.
        NumberOfFrames  % Total number of frames in the video stream. 
        VideoFormat     % Video format as it is represented in MATLAB.
        Width           % Width of the video frame in pixels.
    end

    %------------------------------------------------------------------
    % Undocumented properties
    %------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Dependent, Hidden)
        AudioCompression
        NumberOfAudioChannels
        VideoCompression
    end
    
    %------------------------------------------------------------------
    % Private properties
    %------------------------------------------------------------------
    properties(Access='private', Hidden)
        % To help support future forward compatibility.
        SchemaVersion = 7.11;
        
        % To handle construction on load.
        ConstructorArgs
    end
    
    properties(Access='private', Hidden, Transient)
        % Underlying implementation object.
        VideoReaderImpl 
    end
    
    
    %------------------------------------------------------------------
    % Documented methods
    %------------------------------------------------------------------    
    methods(Access='public')
    
        %------------------------------------------------------------------
        % Lifetime
        %------------------------------------------------------------------
        function obj = VideoReader(fileName, varargin)

            % If no file name provided.
            if nargin == 0
                error('MATLAB:VideoReader:noFile', ...
                      VideoReader.getError('MATLAB:VideoReader:noFile'));
            end

            % Initialize the object.
            obj.init(fileName);

            % Set properties that user passed in.
            if nargin > 1
                set(obj, varargin{:});
            end
        end

        %------------------------------------------------------------------
        % Operations
        %------------------------------------------------------------------        
        varargout = read(obj, varargin)
        inspect(obj)
        
        %------------------------------------------------------------------        
        % Overrides of hgsetset
        %------------------------------------------------------------------        
        getdisp(obj)
        setdisp(obj)

        %------------------------------------------------------------------        
        % Overrides of builtins
        %------------------------------------------------------------------ 
        disp(obj)
        display(obj)
        c = horzcat(varargin)
        c = vertcat(varargin)
    end
    
    methods(Static)
        
        %------------------------------------------------------------------
        % Operations
        %------------------------------------------------------------------

        function supported = isPlatformSupported()
            % ISPLATFORMSUPPORTED Is VIDEOREADER supported on the current platform
            %
            %   ISPLATFORMSUPPORTED will be removed in a future release. 
            %   VIDEOREADER is now supported on all platforms. 
            %
            %   supported = isPlatformSupported() returns true if VIDEOREADER
            %   is supported on the current platform, and false otherwise.
            
            warning('MATLAB:VideoReader:isPlatformSupported:FunctionToBeRemoved', ...
                    'ISPLATFORMSUPPORTED will be removed in a future release.');
                
            supported = audiovideo.mmreader.isPlatformSupported();
        end
        
        function formats = getFileFormats()
            % GETFILEFORMATS
            %
            %    FORMATS = VIDEOREADER.GETFILEFORMATS() returns an object array of 
            %    audiovideo.FileFormatInfo objects which are the formats 
            %    VIDEOREADER is known to support on the current platform. 
            %
            %    The properties of an audiovideo.FileFormatInfo object are:
            %
            %    Extension   - The file extension for this file format
            %    Description - A text description of the file format
            %    ContainsVideo - The File Format can hold video data
            %    ContainsAudio - The File Format can hold audio data
            %
            [extensions, descriptions] = audiovideo.mmreader.getSupportedFormats();
            
            formats = audiovideo.FileFormatInfo.empty();
            for ii=1:length(extensions)
                formats(ii) = audiovideo.FileFormatInfo( extensions{ii}, ...
                                                                xlate(descriptions{ii}), ...
                                                                true, ...
                                                                false );
            end
            
            
            % sort file extension
            [~, sortedIndex] = sort({formats.Extension});
            formats = formats(sortedIndex);
            
            
        end
    end

    methods(Static, Hidden)
        %------------------------------------------------------------------
        % Persistence
        %------------------------------------------------------------------        
        obj = loadobj(B)
    end

    %------------------------------------------------------------------
    % Custom Getters/Setters
    %------------------------------------------------------------------
    methods
        % Properties that are not dependent on underlying object.
        function set.Tag(obj, value)
            if ~(ischar(value) || isempty(value))
                error('MATLAB:class:MustBeString', ...
                      VideoReader.getError('MATLAB:class:MustBeString'));
            end
            obj.Tag = value;
        end
        
        function value = get.Type(obj)
            value = class(obj);
        end
        function set.Type(obj, value)
            obj.setImplValue('Type', value);
        end
        
        % Properties that are dependent on underlying object.
        function value = get.Duration(obj)
            value = obj.getImplValue('Duration');
        end
        function set.Duration(obj, value)
            obj.setImplValue('Duration', value);
        end
        
        function value = get.Name(obj)
            value = obj.getImplValue('Name');
        end
        function set.Name(obj, value)
            obj.setImplValue('Name', value);
        end
        
        function value = get.Path(obj)
            value = obj.getImplValue('Path');
        end
        function set.Path(obj, value)
            obj.setImplValue('Path', value);
        end
        
        function value = get.BitsPerPixel(obj)
            value = obj.getImplValue('BitsPerPixel');
        end
        function set.BitsPerPixel(obj, value)
            obj.setImplValue('BitsPerPixel', value);
        end
        
        function value = get.FrameRate(obj)
            value = obj.getImplValue('FrameRate');
        end
        function set.FrameRate(obj, value)
            obj.setImplValue('FrameRate', value);
        end
        
        function value = get.Height(obj)
            value = obj.getImplValue('Height');
        end
        function set.Height(obj, value)
            obj.setImplValue('Height', value);
        end
        
        function value = get.NumberOfFrames(obj)
            value = obj.getImplValue('NumberOfFrames');
        end
        function set.NumberOfFrames(obj, value)
            obj.setImplValue('NumberOfFrames', value);
        end
        
        function value = get.VideoFormat(obj)
            value = obj.getImplValue('VideoFormat');
        end
        function set.VideoFormat(obj, value)
            obj.setImplValue('VideoFormat', value);
        end
        
        function value = get.Width(obj)
            value = obj.getImplValue('Width');
        end
        function set.Width(obj, value)
            obj.setImplValue('Width', value);
        end
        
        function value = get.AudioCompression(obj)
            value = obj.getImplValue('AudioCompression');
        end
        function set.AudioCompression(obj, value)
            obj.setImplValue('AudioCompression', value);
        end
        
        function value = get.NumberOfAudioChannels(obj)
            value = obj.getImplValue('NumberOfAudioChannels');
        end
        function set.NumberOfAudioChannels(obj, value)
            obj.setImplValue('NumberOfAudioChannels', value);
        end
        
        function value = get.VideoCompression(obj)
            value = obj.getImplValue('VideoCompression');
        end
        function set.VideoCompression(obj, value)
            obj.setImplValue('VideoCompression', value);
        end
    end
    
    %------------------------------------------------------------------        
    % Undocumented methods
    %------------------------------------------------------------------
    methods (Access='public', Hidden)
        
        %------------------------------------------------------------------
        % Lifetime
        %------------------------------------------------------------------
        function delete(obj)
            % Delete VideoReader object.
            delete(obj.getImpl());
        end
   
        %------------------------------------------------------------------
        % Operations
        %------------------------------------------------------------------
        function result = hasAudio(obj)
            result = hasAudio(obj.getImpl());
        end
        
        function result = hasVideo(obj)
            result = hasVideo(obj.getImpl());
        end
    end
    
    methods (Static, Access='public', Hidden)
        
        eMsg = getError(msgID, varargin)
        
        function fullPathName = getFullPathName(fileName)
        % Given a fileName, relative file path, or full file path, return
        % the Full path (i.e. fullpath/fileName.ext) to the given file
        
            % First check the MATLAB path for the file.
            whichFileName = which(fileName);
            if ~strcmp(whichFileName, '')
                fullPathName = whichFileName;
                return;
            end

            % We have file not on the MATLAB path,
            % get the full path using fileattrib.
            [stat info] = fileattrib(fileName);
            if ~stat
                error('MATLAB:VideoReader:fileNotFound', ...
                      VideoReader.getError('MATLAB:VideoReader:fileNotFound'));
            end

            fullPathName = info.Name;
            if strcmp(fullPathName,'')
                error('MATLAB:VideoReader:fileNotFound', ...
                      VideoReader.getError('MATLAB:VideoReader:fileNotFound'));
            end
        end
    end
    
    methods (Static, Access='private', Hidden)
        function errorIfImageFormat( fileName )
            isImageFormat = false;
            try 
                % see if imfinfo recognizes this file as an image
                imfinfo( fileName );
               
                isImageFormat = true;
                
            catch exception %#ok<NASGU>
                % imfinfo does not recognize this file, don't error
                % since it is most likely a valid multimedia file
            end
            
            if isImageFormat
                 % If imfinfo does not error, then show this warning
                error('MATLAB:VideoReader:unsupportedImage', ...
                        'The fileName specified is an image file. Use imread instead of VideoReader.');
            end
        end
    end
    
    %------------------------------------------------------------------
    % Helpers
    %------------------------------------------------------------------
    methods (Access='private', Hidden)

        function init(obj, fileName)
            % Properly initialize the object on construction or load.
            
            fullName = VideoReader.getFullPathName(fileName);
            
            VideoReader.errorIfImageFormat(fullName);
            
            % Save constructor arg for load.
            obj.ConstructorArgs = fullName;
            
            % Create underlying implementation.
            obj.VideoReaderImpl = audiovideo.mmreader(fullName);
       
        end
        
        function impl = getImpl(obj)
            impl = obj.VideoReaderImpl;
        end
        
        function value = getImplValue(obj, propName)
            value = obj.getImpl().(propName);
        end
        
        function setImplValue(obj, propName, value) %#ok<INUSD>
            % All underlying properties are read only. Make the error 
            % the same as a standard MATLAB error when setting externally.
            % TODO: Remove when g449420 is done and used when calling 
            % set() in the constructor.
            err = MException('MATLAB:class:SetProhibited',...
                             VideoReader.getError('MATLAB:class:SetProhibited',...
                                               propName, class(obj)));
            throwAsCaller(err);
        end
        
        function [headings, indices] = getCategoryInfo(obj, propNames)
            % Returns headings and property indices for each category.
            headings = {'General Settings' 'Video Settings', 'Audio Settings'};
            indices = {[] [] []};
            for pi=1:length(propNames)
                propInfo = findprop(getImpl(obj), propNames{pi});
                if isempty(propInfo) || strcmpi(propInfo.Category, 'none')
                    category = 'general';
                else
                    category = propInfo.Category;
                end
                switch category
                    case 'general'
                        indices{1}(end+1) = pi;
                    case 'video'
                        indices{2}(end+1) = pi;
                    case 'audio'
                        indices{3}(end+1) = pi;
                end
            end
        end
    end
    
    methods (Hidden)
        function settableProps = getSettableProperties(obj)
            % Returns a list of publically settable properties.
            % TODO: Reduce to fields(set(obj)) when g449420 is done.
            settableProps = {};
            props = fieldnames(obj);
            for ii=1:length(props)
                p = findprop(obj, props{ii});
                if strcmpi(p.SetAccess,'public')
                    settableProps{end+1} = props{ii}; %#ok<AGROW>
                end
            end
        end
    end
end
