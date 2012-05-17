function ret = vipaviread(arg1,arg2)
%VIPAVIREAD Read AVI file.  Used by Video & Image Processing Blockset's
% From AVI File block.
%   INFOSTRUCT = vipaviread([], FILENAME) opens the AVI file given in 
%   FILENAME for reading.  The file state (including its file ID) is 
%   returned in INFOSTRUCT.
%
%   FRAME = vipaviread(INFOSTRUCT,INDEX) reads the video frame at index INDEX 
%   in the open file whose state is given in INFOSTRUCT.
%
%   vipaviread(INFOSTRUCT) closes the open file whose state is INFOSTRUCT.
%
%   See also AVIINFO, AVIFILE.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/07/27 20:28:34 $

% Validate input/output. 
errmsg = nargoutchk(0,1,nargout);
if ~isempty(errmsg)
    error('VipBlks:vipaviread:invalidOutputArg', errmsg);
end

errmsg = nargchk(1,2,nargin);
if ~isempty(errmsg)
    error('VipBlks:vipaviread:invalidInputArg', errmsg);
end

% three possible scenarios
%   - open a file for reading
%   - read a video frame from an open file
%   - close an open file
if nargin == 1,
    closeFile(arg1);
else
    ret = parseInputArgsAndDispatch(arg1, arg2);
end

%-------------------------------------------------------------------------
function ret = parseInputArgsAndDispatch(arg1, arg2)
if isempty(arg1) && ischar(arg2)
    ret = openFileForReading(arg2);
elseif ~ isempty(arg1) && isnumeric(arg2)
    ret = readVideoFrame(arg1, arg2);
else
    error('VipBlks:vipaviread:unrecognizedInput', ...
          'Unrecognized input arguments');
end


%-------------------------------------------------------------------------
function infoStruct = openFileForReading(filename)

% Initialization
map = [];

[path,name,ext] = fileparts(filename); %#ok
if isempty(ext)
  filename = strcat(filename,'.avi');
end

info = getAviInfo( filename );

if ( isfield(info.MainHeader,'HasIndex') == 0 )
    error('VipBlks:vipaviread:indexParameterNotSupported', ...
          '%s does not support the ''Index'' parameter.',filename);
end

if isempty(strmatch(lower(info.VideoFrameHeader.CompressionType),... 
        {'dib ', 'raw ','none','raw ',char([0 0 0 0])})) %#ok
    error('VipBlks:vipaviread:compressedAVINotSupported', ...
          'Only uncompressed AVI movies can be read on with vipaviread.');
end

if strcmpi(info.VideoFrameHeader.CompressionType,char([0 0 0 0]))
    info.VideoFrameHeader.CompressionType = 'none';
end

fid = fopen(filename,'r','l');
if fid == -1
    error('VipBlks:vipaviread:failedToOpenFile', ...
          'Unable to open %s.', filename);
end

% Find RIFF chunk
[chunk, msg] = findchunk(fid,'RIFF'); %#ok
errorWithFileClose(msg,fid);

% Read AVI chunk
[rifftype,msg] = readfourcc(fid);
errorWithFileClose(msg,fid);
if ( strcmp(rifftype,'AVI ') == 0 )
    error('VipBlks:vipaviread:invalidAVIFile', ...
          'Not a valid AVI file. Missing ''AVI '' chunk.');
end

% Find hdrl LIST chunk
[hdrlsize, msg] = findlist(fid,'hdrl'); %#ok
errorWithFileClose(msg,fid);

% Find and skip avih chunk
[chunk,msg] = findchunk(fid,'avih');
errorWithFileClose(msg,fid);
msg = skipchunk(fid,chunk);
errorWithFileClose(msg,fid);

% Find the video stream
for  i = 1:info.MainHeader.NumStreams
    % Find strl LIST chunk
    [strlsize,msg] = findlist(fid,'strl'); %#ok
    errorWithFileClose(msg,fid);
    % Read strh chunk
    [strhchunk, msg] = findchunk(fid,'strh');
    errorWithFileClose(msg,fid);
    % Determine stream type
    streamType = readfourcc(fid);
    % Break if it is a video stream
    if(strcmp(streamType,'vids'))
        found = 1;
        break;
    else
        found  = 0;
        % Seek to end of strl list minus the amount read
        if ( fseek(fid,listsize - 16,0) == -1 )
            error('VipBlks:vipaviread:incorrectChunkSize', ...
                  'Incorrect chunk size information in AVI file.');
        end
    end
end

if (found == 0)
    error('VipBlks:vipaviread:unableToLocateVideoStream', ...
          'Unable to locate video stream.');
end

% Skip the strh chunk minus the fourcc (4 bytes) already read.
strhchunk.cksize = strhchunk.cksize - 4;
msg = skipchunk(fid,strhchunk);
errorWithFileClose(msg,fid);

% Read strf chunk
[strfchunk, msg] = findchunk(fid,'strf');
errorWithFileClose(msg,fid);

if info.VideoFrameHeader.BitDepth == 24
    % For TrueColor images, skip the Stream Format chunk
    msg = skipchunk(fid,strfchunk);
    errorWithFileClose(msg,fid);
elseif  info.VideoFrameHeader.BitDepth == 8
    % If bitmap has a palette Seek past the BITMAPINFOHEADER to put the
    % file pointer at the beginning of the colormap
    if  fseek(fid,info.VideoFrameHeader.BitmapHeaderSize,0) == -1
        error('VipBlks:vipaviread:incorrectBITMAPINFOHEADER', ...
              'Incorrect BITMAPINFOHEADER size information in AVI file.');
    end
    map = readColormap(fid,info.VideoFrameHeader.NumColorsUsed);
elseif info.VideoFrameHeader.BitDepth == 16
    if  fseek(fid,info.VideoFrameHeader.BitmapHeaderSize,0) == -1
        error('VipBlks:vipaviread:incorrectBITMAPINFOHEADER', ...
              'Incorrect BITMAPINFOHEADER size information in AVI file.');
    end
    map = readColormap(fid,info.VideoFrameHeader.NumColorsUsed);
else
    fclose(fid);
    error('VipBlks:vipaviread:invalidColorFormat', ...
          'Bitmap data must be 24-bit TrueColor images, 16-bit intensity images, or 8-bit Index images');
end

% Search for the movi LIST
[movisize,msg] = findlist(fid,'movi');
errorWithFileClose(msg,fid);
% movioffset will be used when using idx1. The offsets stored in idx1 are
% with respect to just after the 'movi' LIST (not including 'movi')
movioffset = ftell(fid) -4;

% Skip the movi LIST (minus 4 because 'movi' was read) and use idx1.
if ( fseek(fid,movisize-4,0) == -1 )
    error('VipBlks:vipaviread:incorrectChunkSize', ...
          'Incorrect chunk size information in AVI file.');
end
% Find idx1 chunk
[idx1chunk, msg] = findchunk(fid,'idx1'); %#ok
errorWithFileClose(msg,fid);
idx1ChunkPos = ftell(fid);

infoStruct.fid = fid;
infoStruct.idx1ChunkPos = idx1ChunkPos;
infoStruct.movioffset = movioffset;
infoStruct.aviInfo = info;

infoStruct.lastFrameIndex = 0;
infoStruct.lastFrame = [];
infoStruct.lastIdx1 = idx1ChunkPos;

infoStruct.colormap = map;


%-------------------------------------------------------------------------
function infoStruct = readVideoFrame(infoStruct, index)

if ~ isscalar(index),
    error('VipBlks:vipaviread:indexMustBeScalar', 'Index must be a scalar');
end

if index > infoStruct.aviInfo.MainHeader.TotalFrames
    error('VipBlks:vipaviread:invalidFrameIndex', ...
          'Index value exceeds, %d, the total number of movie frames in this AVI movie.', ...
          infoStruct.aviInfo.MainHeader.TotalFrames);
elseif index <= 0
    error('VipBlks:vipaviread:indexMustBePositive', ...
          'Index value must be greater than zero.');
end

fid = infoStruct.fid;
idx1ChunkPos = infoStruct.idx1ChunkPos;
info = infoStruct.aviInfo;

if infoStruct.lastFrameIndex ~= (index - 1),
    % need to seek to the index from the beginning of the index chunk
    fseek(fid,idx1ChunkPos,'bof');
    for i = 1:index
        found = 0;
        while(found == 0)
            id = readfourcc(fid);
            if (strcmpi(id,'00db') || strcmpi(id,'00dc'))
                found = 1;
                infoStruct.lastIdx1 = ftell(fid) - 4; % back 4 from where readfourcc left us
            end
            [idx1data, msg] = readIDX1(fid);
            errorWithFileClose(msg,fid);
        end
    end
else
    % we're reading one frame after the last one, so just start reading
    % from here
    fseek(fid,infoStruct.lastIdx1,'bof');
    found = 0;
    if index==1, goal = 1; else goal = 2; end
    while(found < goal)
        id = readfourcc(fid);
        if (strcmpi(id,'00db') || strcmpi(id,'00dc'))
            found = found + 1;
            infoStruct.lastIdx1 = ftell(fid) - 4; % back 4 from where readfourcc left us
        end
        [idx1data, msg] = readIDX1(fid);
        errorWithFileClose(msg,fid);
    end
end

% Prepare data to be sent to readbmpdata
tempinfo.Filename = info.Filename;
tempinfo.FileID   = fid;
tempinfo.Width = info.VideoFrameHeader.Width;
tempinfo.Height = info.VideoFrameHeader.Height;
tempinfo.BitDepth = info.VideoFrameHeader.BitDepth;

if ~ isfield(infoStruct, 'IsNewFormat'),
    if (idx1data.offset > infoStruct.movioffset)
        infoStruct.IsNewFormat = true;
    else
        infoStruct.IsNewFormat = false;
    end
end

if infoStruct.IsNewFormat
    % If the idx1 offset is greater than the movi offset, then don't
    % add in the movi offset.
    tempinfo.ImageDataOffset = idx1data.offset + 8;
else
    tempinfo.ImageDataOffset = infoStruct.movioffset + idx1data.offset + 8;
end

tempinfo.CompressionType = info.VideoFrameHeader.CompressionType;

infoStruct.lastFrame = readbmpdata(tempinfo);
infoStruct.lastFrameIndex = index;


%-------------------------------------------------------------------------
function closeFile(infoStruct)
try
    status = fclose(infoStruct.fid); %#ok
catch e
    msg = e.message; %#ok
end

%-------------------------------------------------------------------------
function map = readColormap(fid,numColors)
% Read colormap for 8-bit indexed images
map = fread(fid,numColors*4,'*uint8');
map = reshape(map,4,numColors);
map = double(flipud(map(1:3,:))')/255;

%-------------------------------------------------------------------------
function [idx1data,msg] = readIDX1(fid)
% Read the data in the idx1 chunk.
msg = '';
[idx1data.flags, count] = fread(fid,1,'uint32');
if ( count ~= 1 )
  msg = 'Incorrect IDX1 chunk size information in AVI file.';
end
[idx1data.offset, count] = fread(fid,1,'uint32');
if ( count ~= 1 )
  msg = 'Incorrect IDX1 chunk size information in AVI file';
end
[idx1data.length, count] = fread(fid,1,'uint32');
if ( count ~= 1 )
  msg = 'Incorrect IDX1 chunk size information in AVI file';
end

%-------------------------------------------------------------------------
function errorWithFileClose(msg,fid)
%Close open file the error
if ~isempty(msg)
  fclose(fid);
  error('VipBlks:vipaviread:failedToCloseFile', '%s', msg);
end

%-------------------------------------------------------------------------
function info = getAviInfo( filename )
aviinfoWarningID = 'MATLAB:aviinfo:FunctionToBeRemoved';
S = warning('OFF', aviinfoWarningID);
cleaner = onCleanup(@()warning(S));

% Save the state of lastwarn
[preWarningMsg, preWarningID] = lastwarn();

info = aviinfo(filename,'Robust');

[~, lastWarningID] = lastwarn();

% If aviinfo warns about deprecation restore
% the penultimate last warning
if (strcmp(lastWarningID, aviinfoWarningID))
    lastwarn( preWarningMsg, preWarningID );
end