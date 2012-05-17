function varargout = read(obj, varargin)
%READ Read a video file. 
%
%   VIDEO = READ(OBJ) reads in video frames from the associated file.  VIDEO
%   is an H x W x B x F matrix where H is the image frame height, W is the
%   image frame width, B is the number of bands in the image (e.g. 3 for RGB),
%   and F is the number of frames read in.  The default behavior is to read in
%   all frames unless an index is specified.  The type of data returned is 
%   always UINT8 data representing RGB24 video frames.
%
%   VIDEO = READ(...,INDEX) performs the same operation, but reads only the
%   frame(s) specified by INDEX, where the first frame number is 1.  INDEX can
%   be a single index,  or a two-element array representing an index range 
%   of the video stream.
%
%   For example:
%
%      VIDEO = READ(OBJ);           % Read in all video frames.
%      VIDEO = READ(OBJ, 1);        % Read only the first frame.
%      VIDEO = READ(OBJ, [1 10]);   % Read the first 10 frames.
%
%   If any invalid INDEX is specified, MATLAB throws an error.
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
%   See also AUDIOVIDEO, MOVIE, VIDEOREADER, VIDEOREADER/GET, VIDEOREADER/SET, MMFILEINFO.

%    NCH DTL
%    Copyright 2005-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2010/05/10 17:23:08 $

% Error checking.
if ~isa(obj, 'VideoReader')
     error('MATLAB:VideoReader:noVideoReaderObj', ...
           VideoReader.getError('MATLAB:VideoReader:noVideoReaderObj'));
end

if length(obj) > 1
    error('matlab:VideoReader:nonscalar', ...
        VideoReader.getError('matlab:VideoReader:nonscalar'));
end

% ensure that we pass in 1 or 2 arguments only
error(nargchk(1, 2, nargin, 'struct'));

try
    if nargin == 1
        videoFrames = read(getImpl(obj));
    elseif nargin == 2
        if isnumeric(varargin{1})
            index = double(varargin{1});
        else
            index = varargin{1};
        end
        videoFrames = read(getImpl(obj), index);    
    end
catch err
    if strcmpi(err.identifier, 'MATLAB:UndefinedFunction')
        badReadException = MException('MATLAB:VideoReader:invalidreadindex',...
                 VideoReader.getError('MATLAB:VideoReader:invalidreadindex'));
        throw( badReadException );
    else
        rethrow(err);
    end
end

% Video is the output argument.
varargout{1} = videoFrames;

end