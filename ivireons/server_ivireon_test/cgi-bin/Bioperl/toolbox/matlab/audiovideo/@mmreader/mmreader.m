classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
         mmreader < hgsetget
% MMREADER Create a multimedia reader object.
%   MMREADER will be removed in a future release.  Use VideoReader instead.
%   The MMREADER class has been renamed to VideoReader.
%
%   OBJ = MMREADER(FILENAME) constructs a multimedia reader object, OBJ, that
%   can read in video data from a multimedia file.  FILENAME is a string
%   specifying the name of a multimedia file.  There are no restrictions
%   on file extensions.  By default, MATLAB looks for the file FILENAME on
%   the MATLAB path.
%
%   If the object cannot be constructed for any reason (for example, if the
%   file cannot be opened or does not exist, or if the file format is not
%   recognized or supported), then MATLAB throws an error.
%
%   OBJ = MMREADER(FILENAME, 'P1', V1, 'P2', V2, ...) 
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
%      readerobj = mmreader('xylophone.mpg', 'tag', 'myreader1');
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
%   See also AUDIOVIDEO, VideoReader, VideoReader/GET, VideoReader/SET, VideoReader/READ, MMFILEINFO.                
%

%   Authors: NH DL
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.23 $  $Date: 2010/05/10 17:23:28 $

    %------------------------------------------------------------------
    % General properties (in alphabetic order)
    %------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Dependent)
        Duration        % Total length of file in seconds.
        Name            % Name of the file to be read.
        Path            % Path of the file to be read.
    end
    
    properties(Access='public', Dependent)
        Tag = '';       % Generic string for the user to set.
    end
    
    properties(GetAccess='public', SetAccess='private', Dependent)
        Type            % Classname of the object.
    end
    
    properties(Access='public', Dependent)
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
        % Underlying implementation object.
        MMReaderImpl 
    end
    
    
    %------------------------------------------------------------------
    % Documented methods
    %------------------------------------------------------------------    
    methods(Access='public')
    
        %------------------------------------------------------------------
        % Lifetime
        %------------------------------------------------------------------
        function obj = mmreader(fileName, varargin)
            try 
                % If no file name provided.
                if nargin == 0
                    error('MATLAB:mmreader:noFile', ...
                        mmreader.getError('MATLAB:mmreader:noFile'));
                end
                
                % Initialize the object.
                obj.init(fileName);
                
                % Set properties that user passed in.
                if nargin > 1
                    set(obj, varargin{:});
                end
            catch exception
                throwAsCaller( mmreader.convertException( exception ) );
            end
        end

        %------------------------------------------------------------------
        % Operations
        %------------------------------------------------------------------        
        varargout = read(obj, varargin)
        
        function inspect(obj)
            %INSPECT Open the inspector and inspect mmreader object properties.
            %
            %    INSPECT(OBJ) opens the property inspector and allows you to
            %    inspect and set properties for the mmreader object, OBJ.
            %
            %    Example:
            %        r = mmreader('myfilename.avi');
            %        inspect(r);
            try
                inspect(obj.getImpl());
            catch exception
                throwAsCaller( mmreader.convertException( exception ) );
            end
        end
        
        %------------------------------------------------------------------        
        % Overrides of hgsetset
        %------------------------------------------------------------------        
        function getdisp(obj)
            % Create the property display for GET(OBJ).
            try
                obj.getImpl().getdisp();
            catch exception
                throwAsCaller( mmreader.convertException( exception ) );
            end
        end
        
        
        function setdisp(obj)
            try
                % Create the property display for SET(OBJ).
                obj.getImpl.setdisp();
            catch exception
                throwAsCaller( mmreader.convertException( exception ) );
            end
        end

        %------------------------------------------------------------------        
        % Overrides of builtins
        %------------------------------------------------------------------ 
        function disp(obj)
            %DISP Display method for mmreader objects.
            %
            %    DISP(OBJ) displays information pertaining to the mmreader object.
            %
            %    See also MMREADER/GET.
            try
                obj.getImpl().disp();
            catch exception
                throwAsCaller( mmreader.convertException( exception ) );
            end
        end

        function display(obj)
            %DISPLAY Display method for mmreader objects.
            %
            %    DISPLAY(OBJ) displays information pertaining to the mmreader object.
            %
            %    See also MMREADER/GET.
            try
                disp(obj);
            catch exception
                throwAsCaller( mmreader.convertException( exception ) );
            end                
        end
        
        function c = horzcat(varargin)
            %HORZCAT Horizontal concatenation of mmreader objects.
            %
            %    See also MMREADER/VERTCAT.
            if (nargin == 1)
                c = varargin{1};
            else
                error('MATLAB:mmreader:nocatenation',...
                    mmreader.getError('MATLAB:mmreader:nocatenation'));
            end
        end
        
        function c = vertcat(varargin)
            %VERTCAT Vertical concatenation of mmreader objects.
            
            if (nargin == 1)
                c = varargin{1};
            else
                error('MATLAB:mmreader:nocatenation',...
                    mmreader.getError('MATLAB:mmreader:nocatenation'));
            end
        end
        
    end
    
    methods(Static)
        
        %------------------------------------------------------------------
        % Operations
        %------------------------------------------------------------------

        function supported = isPlatformSupported()
            % ISPLATFORMSUPPORTED Is MMREADER supported on the current platform
            %
            %   ISPLATFORMSUPPORTED will be removed in a future release. 
            %   MMREADER is now supported on all platforms. 
            %
            %   supported = isPlatformSupported() returns true if MMREADER
            %   is supported on the current platform, and false otherwise.
         
            % turn off the matlab:VideoReader:unknownNumFrames warning
            warnState=warning('off','MATLAB:VideoReader:isPlatformSupported:FunctionToBeRemoved');
            c = onCleanup(@()warning(warnState));
         
            supported = VideoReader.isPlatformSupported();
            
            warning('MATLAB:mmreader:isPlatformSupported:FunctionToBeRemoved', ...
                'ISPLATFORMSUPPORTED will be removed in a future release.');
    
        end
        
        function formats = getFileFormats()
            % GETFILEFORMATS
            %
            %    FORMATS = MMREADER.GETFILEFORMATS() returns an object array of 
            %    audiovideo.FileFormatInfo objects which are the formats 
            %    MMREADER is known to support on the current platform. 
            %
            %    The properties of an audiovideo.FileFormatInfo object are:
            %
            %    Extension   - The file extension for this file format
            %    Description - A text description of the file format
            %    ContainsVideo - The File Format can hold video data
            %    ContainsAudio - The File Format can hold audio data
            %
            
            formats = VideoReader.getFileFormats();
        end
    end

    methods(Static, Hidden)
        
        eMsg = getError(msgId, varargin);
        
        %------------------------------------------------------------------
        % Persistence
        %------------------------------------------------------------------        
        obj = loadobj(B)
    end

    %------------------------------------------------------------------
    % Custom Getters/Setters
    %------------------------------------------------------------------
    methods
        % Properties that are dependent on underlying object.
        function value = get.Tag(obj)
            value = obj.getImplValue('Tag');
        end
        
        function set.Tag(obj, value)
            obj.setImplValue('Tag', value);
        end
        
        function value = get.Type(obj)
            value = class(obj);
        end
        function set.Type(obj, value)
            obj.setImplValue('Type', value);
        end
        
        function value = get.UserData(obj)
            value = obj.getImplValue('UserData');
        end
        function set.UserData(obj, value)
            obj.setImplValue('UserData',value);
        end
        
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
        function fullPathName = getFullPathName(fileName)
            % Given a fileName, relative file path, or full file path, 
            % return the Full path (i.e. fullpath/fileName.ext) to 
            % the given file
            try
                fullPathName = VideoReader.getFullPathName(fileName);
            catch exception
                throwAsCaller( mmreader.convertException( exception ) );
            end
        end
    end
    
    %------------------------------------------------------------------
    % Helpers
    %------------------------------------------------------------------
    methods (Access='private', Hidden)
        function init(obj, fileName)
            
            % turn off the matlab:VideoReader:unknownNumFrames warning
            warnID = 'MATLAB:VideoReader:unknownNumFrames';
            warnState(1)=warning('off', warnID );
            warnState(2)=warning('off','backtrace');
            c = onCleanup(@()warning(warnState));
                       
            
            % Create underlying implementation.
            obj.MMReaderImpl = VideoReader(fileName);
            
            % Transform the unknown VideoReader:unknownNumFrames
            % warning into mmreader:unknownNumFrames
            [lastWarnMsg, lastWarnID] = lastwarn;
            if (strcmpi(warnID, lastWarnID))
                newWarnId = strrep(lastWarnID, ':VideoReader:',':mmreader:');
                warning( newWarnId, lastWarnMsg );
            end
        end
        
        function impl = getImpl(obj)
            impl = obj.MMReaderImpl;
        end
        
        function value = getImplValue(obj, propName)
            value = obj.getImpl().(propName);
        end
        
        function setImplValue(obj, propName, value) 
            obj.getImpl().(propName) = value;
        end
        
        function settableProps = getSettableProperties(obj)
            settableProps = obj.getImpl().getSettableProperties();
        end
    end
    
    methods(Static, Access='private') 
        function exception = convertException( exception )  
            % Replace error ID's  and messages using VideoReader 
            % with mmreader to preserve backward compatiblity
            newId = strrep( exception.identifier, ...
                ':VideoReader:', ...
                ':mmreader:');
            
            newMessage = strrep( exception.message, ...
                'VideoReader', ...
                'mmreader');
            
            exception = MException( newId, newMessage );      
        end
    end
end
