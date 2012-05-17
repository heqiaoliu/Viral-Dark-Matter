function varargout = read(obj, varargin)
%READ Read a multimedia file. 
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
%   See also AUDIOVIDEO, MOVIE, MMREADER, MMREADER/GET, MMREADER/SET, MMFILEINFO.

%    NCH DTL
%    Copyright 2005-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.13 $  $Date: 2010/05/10 17:23:29 $

% Error checking.
if ~isa(obj, 'mmreader')
     error('MATLAB:mmreader:noMmreaderObj', ...
           mmreader.getError('MATLAB:mmreader:noMmreaderobj'));
end

if length(obj) > 1
    error('matlab:mmreader:nonscalar', ...
        mmreader.getError('matlab:mmreader:nonscalar'));
end

try
    varargout{1} = read(obj.getImpl(), varargin{:});
catch exception
    throwAsCaller( mmreader.convertException( exception ) );
end

end