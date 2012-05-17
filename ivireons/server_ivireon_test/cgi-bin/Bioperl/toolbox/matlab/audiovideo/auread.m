function [y,Fs,bits,opts]=auread(file,ext)
%AUREAD Read NeXT/SUN (".au") sound file.
%   Y=AUREAD(AUFILE) loads a sound file specified by the string AUFILE,
%   returning the sampled data in y. The ".au" extension is appended
%   if no extension is given.  Amplitude values are in the range [-1,+1].
%   Supports multi-channel data in the following formats:
%   8-bit mu-law, 8-, 16-, and 32-bit linear, and floating point.
%
%   [Y,Fs,BITS]=AUREAD(AUFILE) returns the sample rate (Fs) in Hertz
%   and the number of bits per sample (BITS) used to encode the
%   data in the file.
%
%   [...]=AUREAD(AUFILE,N) returns only the first N samples from each
%       channel in the file.
%   [...]=AUREAD(AUFILE,[N1 N2]) returns only samples N1 through N2 from
%       each channel in the file.
%   SIZ=AUREAD(AUFILE,'size') returns the size of the audio data contained
%       in the file in place of the actual audio data, returning the
%       vector SIZ=[samples channels].
%
%   See also AUWRITE, WAVREAD.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/04/21 16:24:58 $

%   D. Orofino, 10/95

if nargin>2,
  error('MATLAB:auread:tooManyInputs','Too many input arguments.');
end
% Append extension if it's missing:
if isempty(findstr(file,'.')),
  file=[file '.au'];  % or .snd
end
fid=fopen(file,'rb','b');   % Big-endian
if fid == -1,
  error('MATLAB:auread:unableToOpenFile','Can''t open NeXT/SUN sound file for input.');
end

% No optional information is read from this file format.
opts = [];

% Now the file is open - wrap remaining code in try/catch so we can 
% close the file if an error occurs
try

% Read header:
snd = read_sndhdr(fid);
% Parse structure info for return to user:
Fs = snd.rate; bits = snd.bits;

% Determine if caller wants data:
if nargin<2, ext=[]; end    % Default - read all samples
exts=numel(ext);
if strncmpi(ext,'size',exts),
  % Caller doesn't want data - just data size:
  fclose(fid);
  y = [snd.samples snd.chans];
  return;
elseif exts>2,
  error('MATLAB:auread:invalidIndexRange','Index range must be specified as a scalar or 2-element vector.');
elseif (exts==1),
  ext=[1 ext];  % Prepend start sample index
end

% Read data:
snd = read_sndata(fid,snd,ext);
y = snd.data; 

catch exception
    fclose(fid);
    rethrow( exception );
end

fclose(fid);

% end of auread()


% ------------------------------------------------------------------------
% Private functions:
% ------------------------------------------------------------------------

% READ_SNDHDR: Read sound file header structure
%   Assumes fid points to the start of an open file.
%   Returns a structure if successful.
function snd = read_sndhdr(fid)
% Read file header:
snd.magic = char(fread(fid,4,'char')');
if ~strcmp(snd.magic,'.snd'),
  error('MATLAB:auread:InvalidAUFile','Not a NeXT/Sun sound file.'); 
end
snd.offset = fread(fid,1,'uint32');
snd.databytes = fread(fid,1,'uint32');
snd.format = fread(fid,1,'uint32');
snd.rate = fread(fid,1,'uint32');
snd.chans = fread(fid,1,'uint32');

% Directly determine how long info string is:
info_len = snd.offset-24;
[info,cnt] = fread(fid,info_len,'char');
snd.info = deblank(char(info'));
if cnt~=info_len,
  error('MATLAB:auread:errorReadingFile','Error while reading sound file.'); 
end

% For some file types, the .databytes field seems to have
% an invalid file length.  Directly determine file length
% for all cases:
fseek(fid,0,1);             % Go to end of file
file_len = ftell(fid);      % Get position in bytes
fseek(fid,snd.offset,-1);   % Reposition file pointer
snd.databytes = file_len-snd.offset;

% Interpret format:
switch snd.format
case 1
    snd.bits=8;% 8-bit mu-law
case 2
    snd.bits=8;% 8-bit linear
case 3
    snd.bits=16; % 16-bit linear
case 5
    snd.bits=32;% 32-bit linear
case 6
    snd.bits=32;% Single precision
case 7
    snd.bits=64;% Double-precision
otherwise
    error('MATLAB:auread:invalidDataFormat','Unrecognized data format.'); 
end

% Determine # of samples per channel:
snd.samples = snd.databytes*8/snd.bits/snd.chans;
if snd.samples~=fix(snd.samples),
  error('MATLAB:auread:truncatedDataFile','Truncated data file.'); 
end

return;

% READ_SNDATA: Read sound file header structure
%   Assumes fid points to the start of an open file.
%   Returns a structure if successful.
%
function new_snd = read_sndata(fid,snd,ext)
  SamplesPerChannel = snd.samples;
  BytesPerSample = snd.bits/8;

  % Interpret format:
switch snd.format
case 1
    dtype='uchar';% 8-bit mu-law
case 2
    dtype='int8';% 8-bit linear
case 3
    dtype='int16'; % 16-bit linear
case 5
    dtype='int32';% 32-bit linear
case 6
    dtype='float';% Single precision
case 7
    dtype='double';% Double-precision
otherwise
    error('MATLAB:auread:invalidDataFormat','Unrecognized data format.'); 
end

  % Determine sample range to read:
  if isempty(ext),
    ext = [1 SamplesPerChannel];    % Return all samples
  else
    if numel(ext)~=2,
      error('MATLAB:auread:invalidLimitVector','Sample limit vector must have 2 elements.'); 
    end
    if ext(1)<1 || ext(2)>SamplesPerChannel,
      error('MATLAB:auread:sampleLimitsOutOfRange','Sample limits out of range.'); 
    end
    if ext(1)>ext(2),
      error('MATLAB:auread:sampleLimitsOutOfOrder','Sample limits must be given in ascending order.');
    end
  end
  % Skip over leading samples:
  if ext(1)>1,
    % Skip over leading samples, if specified:
    status = fseek(fid,BytesPerSample*(ext(1)-1)*snd.chans,0);
    if status==-1,
      error('MATLAB:auread:invalidFileFormat','Error in file format.');
    end
  end
  % Read desired data:
  nSPCext = ext(2)-ext(1)+1; % # samples per channel in extraction range
  extSamples = snd.chans*nSPCext;
  [data,cnt] = fread(fid, [snd.chans nSPCext], dtype);
  if cnt~=extSamples,
    error('MATLAB:auread:truncatedDataFile','Data file is truncated.');
  end
  % Rearrange data into a matrix with one channel per column:
  data = data';

  % Convert and normalize data range:
switch snd.format
case 1
    data = mu2lin(data);% 8-bit mu-law
case 2
    data = data*2^(-7);% 8-bit linear
case 3
    data = data*2^(-15); % 16-bit linear
case 5
    data = data*2^(-31); % 32-bit linear
case {6,7}
    a=min(min(data)); b=max(max(data));
    data=(data-a)/(b-a)*2-1;%float , double
otherwise
    error('MATLAB:auread:invalidDataFormat','Unrecognized data format.');
end
  new_snd = snd;
  new_snd.data = data;
return;

% end of auread.m
