function [aviobj] = addframe(aviobj,varargin)
%ADDFRAME  Add video frame to AVI file.  
%   AVIOBJ = ADDFRAME(AVIOBJ,FRAME) appends the data in FRAME to AVIOBJ,
%   which is created with AVIFILE.  FRAME can be either an indexed image
%   (M-by-N) or a truecolor image (M-by-N-by-3) of double or uint8
%   precision.  If FRAME is not the first frame added to the AVI file, it
%   must be consistent with the dimensions of the previous frames.
%   
%   AVIOBJ = ADDFRAME(AVIOBJ,FRAME1,FRAME2,FRAME3,...) adds multiple
%   frames to an avifile.
%
%   AVIOBJ = ADDFRAME(AVIOBJ,MOV) appends the frame(s) contained in the
%   MATLAB movie MOV to the AVI file. MATLAB movies which store frames as
%   indexed images will use the colormap in the first frame as the colormap
%   for the AVI file unless the colormap has been previously set.
%
%   AVIOBJ = ADDFRAME(AVIOBJ,H) captures a frame from the figure or
%   axis handle H, and appends this frame to the AVI file. The frame is
%   rendered into an offscreen array before it is appended to the AVI file.
%   This syntax should not be used if the graphics in the animation are using
%   XOR graphics.
%
%   If the animation is using XOR graphics, use GETFRAME instead to capture
%   the graphics into one frame of a MATLAB movie and then use the syntax
%   [AVIOBJ] = ADDFRAME(AVIOBJ,MOV) as in the example below. GETFRAME will
%   perform a snapshot of the onscreen image.
% 
%   Example: 
%
%      t = linspace(0,2.5*pi,40);
%      fact = 10*sin(t);
%      fig=figure;
%      aviobj = avifile('example.avi')
%      [x,y,z] = peaks;
%      for k=1:length(fact)
%          h = surf(x,y,fact(k)*z);
%          axis([-3 3 -3 3 -80 80])
%          axis off
%          caxis([-90 90])
%          F = getframe(fig);
%          aviobj = addframe(aviobj,F);
%      end
%      close(fig)
%      aviobj = close(aviobj);
%
%   See also AVIFILE, AVIFILE/CLOSE, and MOVIE2AVI.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2008/04/06 19:16:05 $

numframes = nargin - 1;
error(nargoutchk(1,1,nargout));
if ~isa(aviobj,'avifile')
  error('MATLAB:addframe:invalidAviFileObjectInput','First input must be an avifile object.');
end

for i = 1:numframes
  MovieLength = 1;
  mlMovie = 0;
  % Parse input arguments
  inputType = getInputType(varargin{i});
  switch inputType
   case 'axes'
    frame = getFrameForFigure(get(varargin{i},'parent'));
   case 'figure'
    frame = getFrameForFigure(varargin{i});
   case 'movie'
    mlMovie = 1;
    MovieLength = length(varargin{i});
    if ( ~isempty(varargin{i}(1).colormap) && ...
	 isempty(aviobj.Bitmapheader.Colormap) && ...
	 aviobj.MainHeader.TotalFrames == 0 )
      aviobj = set(aviobj,'Colormap',varargin{i}(1).colormap);
    end
   case 'data'
    frame = varargin{i};
  end

  for j = 1:MovieLength
    if mlMovie 
      frame = varargin{i}(j).cdata;
    end
    
    frameClass = class(frame);
    if isempty(strmatch(frameClass,strvcat('double','uint8')))
      error('MATLAB:addframe:invalidFrameType','FRAME must be of either double or uint8 precision');
    end
        
    % Determine image dimensions
    height = size(frame,1); 
    width = size(frame,2);
    dims = size(frame,3);

    % Check requirements for the Intel Indeo codec
    % Intel Indeo requires images dimensions to be a multiple of four,
    % greater than 32, and no more than 4,194,304 pixels.
    isIndeo = strncmpi('iv',aviobj.StreamHeader.fccHandler, 2);

    if isIndeo
      if (aviobj.MainHeader.TotalFrames == 0) && ...
	    (aviobj.Bitmapheader.biBitCount == 8) && ...
	    (aviobj.Bitmapheader.biClrUsed >236)
            error('MATLAB:addframe:invalidIndeoColorMapSize','The colormap can not exceed 236 colors, as specified by the Intel Indeo compressor.');
      end
            
      if (width < 32) || (height < 32)
        error('MATLAB:addframe:indeoFrameSizeTooSmall','The minimum frame size for the Indeo compressor is 32x32.');
      end
      if width*height > 4194304
        error('MATLAB:addframe:indeoFrameSizeTooLarge','The Intel Indeo compressor can not compress frame sizes that exceed a maximum frame size of 4,194,304 pixels.');
      end
    end % if isIndeo

    % Check requirements for MPEG-4 compressors.  This list is maintained
    % from Microsoft's list of registered codecs:
    % http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnwmt/html/registeredfourcccodesandwaveformats.asp
    codec = aviobj.StreamHeader.fccHandler;
    isMPG4 = any(strncmpi(codec, {'M4S2', 'MP43', 'MP42', 'MP4S', 'MP4V'}, 4));
    
    % Indeo and MPEG-4 codecs require that frame height and width
    % are multiples of 4.
    if isMPG4 || isIndeo
        hpad = rem(height,4);
        wpad = rem(width,4);
        if hpad
            if  aviobj.MainHeader.TotalFrames == 0
                warning('MATLAB:aviaddframe:frameheightpadded','The frame height has been padded to be a multiple of four as required by the specified codec.');
            end
            frame = [frame;zeros(4-hpad,size(frame,2),dims)];
        end
        if wpad
            if  aviobj.MainHeader.TotalFrames == 0
                warning('MATLAB:aviaddframe:framewidthpadded','The frame width has been padded to be a multiple of four as required by the specified codec.');
            end
            frame = [frame, zeros(size(frame,1),4-wpad,dims)];
        end

        % Determine adjusted image dimensions
        height = size(frame,1);
        width = size(frame,2);
        dims = size(frame,3);
    end
    
    % Truecolor images can not be compressed with RLE or MSVC compression 
    if dims == 3
      msg = 'Use a compression method other than RLE or MSVC for truecolor images.';
      msgID = 'MATLAB:addframe:invalidCompressionType';
      if strmatch(lower(aviobj.StreamHeader.fccHandler),'mrle') 
        error(msgID,msg);
      elseif strmatch(lower(aviobj.StreamHeader.fccHandler),'msvc')
        error(msgID,msg);
      end
    end
    
    % If this is not the first frame, make sure it is consistent
    if aviobj.MainHeader.TotalFrames ~= 0
      ValidateFrame(aviobj,width, height,dims);
    end

    % Reshape image data
    frame = ReshapeImage(frame);

    % Compute memory requirements for frame storage
    numFrameElements = prod(size(frame));

    % If this is the first frame, set necessary fields
    if aviobj.MainHeader.TotalFrames==0
      aviobj.MainHeader.SuggestedBufferSize = numFrameElements;
      aviobj.StreamHeader.SuggestedBufferSize = numFrameElements;
      aviobj.MainHeader.Width = width;
      aviobj.MainHeader.Height = height;
      aviobj.Bitmapheader.biWidth = width;
      aviobj.Bitmapheader.biHeight = height;
      aviobj.Bitmapheader.biSizeImage = numFrameElements;
      if dims == 3 
	aviobj.Bitmapheader.biBitCount = 24;
      else
	aviobj.Bitmapheader.biBitCount = 8;
      end
    end

    % On Windows use Video for Windows to write the video stream
    if ispc
      % fps is calculated in avi.c by dividing the rate by the scale (100).
      % The scale of 100 is hard coded into avi.c
      rate = aviobj.StreamHeader.Rate; 
    
      avi('addframe',rot90(frame,-1), aviobj.Bitmapheader, ...
	  aviobj.MainHeader.TotalFrames,rate, ...
	  aviobj.StreamHeader.Quality,aviobj.FileHandle, ...
	  aviobj.StreamName,aviobj.KeyFrameEveryNth);
    end
    
    if isunix
    
      % Determine and update new size of movi LIST
      % ------------------------------------------
      %   '00db' or '00dc'   4 bytes
      %   size               4 bytes
      %   <movie data>       N
      %   Padd byte          rem(numFrameElements,2)
      newMovieListSize = aviobj.Sizes.movilist+4+4+numFrameElements + ...
	  rem(numFrameElements,2);
      aviobj.Sizes.movilist = newMovieListSize;

      % Determine and update new size of idx1 chunk
      % ------------------------------------------
      %   '00db' or '00dc'   4 bytes
      %   flags              4 bytes
      %   offset             4 bytes
      %   length             4 bytes
      newidx1size = aviobj.Sizes.idx1size + 4*4; 
      aviobj.Sizes.idx1size = newidx1size;

      % Determine and update new size of RIFF chunk
      % ------------------------------------------
      %   '00db' or '00dc'   4 bytes
      %   size               4 bytes
      %   <movie data>       N
      %   Padd byte          rem(numFrameElements,2)
      %   '00db' or '00dc'   4 bytes
      %   flags              4 bytes
      %   offset             4 bytes
      %   length             4 bytes
      newRIFFsize = aviobj.Sizes.riffsize + 4+4+numFrameElements + 4*4 ...
	  + rem(numFrameElements,2);
      aviobj.Sizes.riffsize = newRIFFsize;

      % Write  movi chunk to temp file
      if aviobj.Compression == 1
    	ckid = '00dc';
      else
        ckid = '00db';
      end
      [msgID msg] = WriteTempdata(ckid,numFrameElements,frame,aviobj.TempDataFile);
      error(msgID,msg);
    end %End of UNIX specific code

  % Update the total frames
  aviobj.MainHeader.TotalFrames = aviobj.MainHeader.TotalFrames + 1;
  
  % Always make sure the main header and stream header length
  % match the total # of frames.
  aviobj.MainHeader.Length = aviobj.MainHeader.TotalFrames;
  aviobj.StreamHeader.Length = aviobj.MainHeader.TotalFrames;
  end
end
return;

% ------------------------------------------------------------------------
function [msgID msg] = WriteTempdata(chunktype,chunksize,chunkdata,filename)
% WRITETEMPDATA 
%   Append the frame data to a temporary file. The data is written as
% 
%   chunktype  4 bytes
%   chunksize  4 bytes
%   chunkdata  N bytes  
%   

msgID= '';
msg = '';
fid = fopen(filename,'a','l');
fseek(fid,0,'eof');

count = fwrite(fid,chunktype,'char');
if count ~= 4
  msgID = 'MATLAB:addframe:unableToWriteTempFile';
  msg = 'Unable to write data to temp file.';
end

count = fwrite(fid,chunksize,'uint32');
if count ~= 1
  msgID = 'MATLAB:addframe:unableToWriteTempFile';
  msg = 'Unable to write data to temp file.';
end

count = fwrite(fid,rot90(chunkdata,-1),'uint8');
if count ~= prod(size(chunkdata))
  msgID = 'MATLAB:addframe:unableToWriteTempFile';
  msg = 'Unable to write data to temp file.';
end

fclose(fid);
return;

% ------------------------------------------------------------------------
function ValidateFrame(aviobj, width, height, dims)
% VALIDATEFRAME
%   Verify the frame is consistent with header information in AVIOBJ.  The
%   frame must have the same WIDTH, HEIGHT, and DIMS as the previous frames.

if width ~= aviobj.MainHeader.Width
  error('MATLAB:addframe:invalidFrameSize','Frame must be %d by %d.', ...
		aviobj.MainHeader.Width,aviobj.MainHeader.Height)
elseif height ~= aviobj.MainHeader.Height
  error('MATLAB:addframe:invalidFrameSize','Frame must be %d by %d.', ...
		aviobj.MainHeader.Width,aviobj.MainHeader.Height)
end

if (aviobj.Bitmapheader.biBitCount == 24) && (dims ~= 3)
  error('MATLAB:addframe:invalidColorBitDepth','Frame must be a truecolor image.');
elseif (aviobj.Bitmapheader.biBitCount == 8) && (dims ~= 1)
  error('MATLAB:addframe:invalidColorBitDepth','Frame must be an indexed image.')
end
return;

% ------------------------------------------------------------------------
function X = ReshapeImage(X)
numdims = ndims(X);
numcomps = size(X,3);

if (isa(X,'double'))
  if (numcomps == 3)
    X = uint8(round(255*X));
  else
    X = uint8(X-1);
  end
end

% Squeeze 3rd dimension into second
if (numcomps == 3)
  X = X(:,:,[3 2 1]);
  X = permute(X, [1 3 2]);
  X = reshape(X, [size(X,1) size(X,2)*size(X,3)]);
end

width = size(X,2);
tmp = rem(width,4);
if (tmp > 0)
    padding = 4 - tmp;
    X = cat(2, X, repmat(uint8(0), [size(X,1) padding]));
end

return;

% ------------------------------------------------------------------------
function inputType = getInputType(frame)
  if isscalar(frame) && ishandle(frame) && (frame > 0)
    inputType = get(frame,'type');
  elseif isstruct(frame) && isfield(frame,'cdata')
    inputType = 'movie';
  elseif isa(frame,'numeric')
    inputType = 'data';
  else
    error('MATLAB:addframe:invalidInputType','Invalid input argument.  Each frame must be a numeric matrix, a MATLAB movie structure, or a handle to a figure or axis.');
  end

% ------------------------------------------------------------------------
function frame = getFrameForFigure( figHandle )
    % make sure the figures units are in pixels
    oldUnits = get( figHandle, 'Units');
    set( figHandle, 'Units', 'pixels');
    unitCleanup = onCleanup( @()set(figHandle, 'Units', oldUnits) );
    
    pixelsperinch = get(0,'screenpixelsperInch');
    pos =  get( figHandle,'position');
    
    set(figHandle, 'paperposition', pos./pixelsperinch);
    renderer = get(figHandle,'renderer');
    if strcmp(renderer,'painters')
        renderer = 'opengl';
    end
    %Turn off warning in case opengl is not supported and
    %hardcopy needs to use zbuffer
    warnstate = warning('off','MATLAB:addframe:warningsTurnedOff');
    warnCleanup = onCleanup( @()warning(warnstate) );

    frame = hardcopy(figHandle, ['-d' renderer], ['-r' num2str(round(pixelsperinch))]);
    
