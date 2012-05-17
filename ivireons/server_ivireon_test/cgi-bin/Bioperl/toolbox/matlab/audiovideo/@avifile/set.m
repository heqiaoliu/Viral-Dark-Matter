function obj = set(obj,varargin)
%SET Set properties of AVIFILE objects.
%
% OBJ = SET(OBJ,'PropertyName',VALUE) sets the property 'PropertyName' of
% the AVIFILE object OBJ to the value VALUE.  
%
% OBJ = SET(OBJ,'PropertyName',VALUE,'PropertyName',VALUE,..) sets multiple
% property values of the AVIFILE object OBJ with a single statement.
%
%   Note: This function is a helper function for SUBSASGN and not intended
%   for users.  Structure notation should be used to set property values of
%   AVIFILE objects.  For example:
%
%       obj.Fps = value;
%

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2009/12/31 18:50:56 $

if nargout ~=1
  error('MATLAB:aviset:invalidOutputArgument','You must use the syntax obj=set(obj,....).');
end

if rem(length(varargin),2)
  error('MATLAB:aviset:mismatchedPropValPairs','The property/value inputs must always occur as pairs.');
end

numPairs = length(varargin)/2;
  
paramNames =  {'fps','compression','quality','colormap','videoname',...
               'keyframepersec'};
paramSetFcns = {'setFps','setCompression','setQuality', ...
                'setColormap','setName','setKeyFrame'};

[params,idx] = sort(varargin(1:2:end));
values = varargin(2:2:end);
values = values(idx);

for i = 1:numPairs
  match = strmatch(lower(params{i}),paramNames);
  switch length(match)
   case 1
    obj = feval(paramSetFcns{match},obj,values{i});
   case 0
    error('MATLAB:aviset:invalidParameterName','Unrecognized parameter name ''%s''.', params{i});
   otherwise % more than one match
    error('MATLAB:aviset:ambiguousParameterName', 'Ambiguous parameter name ''%s''.', params{i});
  end % switch
end
return;

% ------------------------------------------------------------------------
function obj = setKeyFrame(obj,value)

if obj.MainHeader.TotalFrames ~= 0
  error('MATLAB:aviset:keyFrameRateNotSet','The key frame rate must be set before calling ADDFRAME.');
end

if value <= 0
  error('MATLAB:aviset:invalidKeyFrameRate','The number of key frames per second must be greater than zero.');
end

% Convert number of key frames per second to key frames per N frames
obj.KeyFrameEveryNth = floor(1/(obj.MainHeader.Fps/10^6)/value);
return;

% ------------------------------------------------------------------------
function obj = setName(obj,value)
% Set a descriptive name to the video stream.

if obj.MainHeader.TotalFrames ~= 0
  error('MATLAB:aviset:streamNameNotSet','The name must be set before calling ADDFRAME.');
end

if ~isa(value,'char')
  error('MATLAB:aviset:invalidStreamName','The stream name must be a string.');
end

if length(value) > 64
  error('MATLAB:aviset:invalidStreamNameLength','The video stream name must be no more than 64 characters long');
end

% Calculate size difference from current frame
dif = length(obj.StreamName) - length(value) + 1;

obj.StreamName = value;
if isunix
  obj.Sizes.strnsize = length(value)+1+8;
end
return;

% ------------------------------------------------------------------------
function obj = setFps(obj, value)

if obj.MainHeader.TotalFrames ~= 0
  error('MATLAB:aviset:fpsNotSet','Fps must be set before calling ADDFRAME.');
end

if value <= 0
  error('MATLAB:aviset:fpsTooSmall','The number of frames per second must be greater than zero.');
end

if value<1 & strcmp(obj.StreamHeader.fccHandler,'iv32')
  error('MATLAB:aviset:fpsInvalidForIndeo3','FPS must be 1 or greater for compression with Indeo3.');
end

% The number of key frames per second needs to be updated
CurrentKeyFramePerSec = 10^6/obj.MainHeader.Fps/obj.KeyFrameEveryNth;
obj.KeyFrameEveryNth = value/CurrentKeyFramePerSec;

% Fps is stored in micro seconds per frame
obj.MainHeader.Fps = 10^6/value;
obj.MainHeader.Rate = value*100;
obj.StreamHeader.Rate = value*100;

return;

% ------------------------------------------------------------------------
function obj = setCompression(obj,value)

if isunix && ~(strcmpi(value,'none') || strcmpi(value, 'dib '))
  unixName = 'UNIX';
  if (ismac)
      unixName = 'Mac';
  end
  error('MATLAB:aviset:invalidCompressionType','Only uncompressed AVI files can be written on %s',unixName);
end

if ispc && ~isIndeoRequestValid(value)
  error('MATLAB:set:invalidCodec', ...
      ['Indeo codecs are not supported in this version of Windows.  Please specify a different codec.\nSee ' ...
       privateGetInvalidCodecReference() ' for more information.']);
end

if strcmpi(computer,'PCWIN64') && strcmpi(value,'Cinepak')
  error('MATLAB:aviset:invalidCinepakCodec', ...
        'The Cinepak codec is not supported in this version of Windows. Please specify a different codec.');
end

msg = 'Compressor must be ''Cinepak'', ''Indeo3'', ''Indeo5'', ''MSVC'', ''RLE'', ''None'', or a four character compression code (fourcc).';
msgID = 'MATLAB:aviset:unknownCodec';
if ~isa(value,'char')
  error(msgID,msg);
end

% The compression must be set before the first frame is added to the file.
if obj.MainHeader.TotalFrames ~= 0
  error('MATLAB:aviset:compressionSetLate','Compression must be set before any frames are added.');
end

switch lower(value)
 case 'none'
  obj.Compression = 0;
  obj.StreamHeader.fccHandler = 'DIB ';
  obj.Bitmapheader.biCompression = 'DIB ';
 case 'rle'
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = 'MRLE';
  obj.Bitmapheader.biCompression = 'mrle';
 case 'cinepak'
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = 'cvid';
  fourcc = 'cvid';
  obj.Bitmapheader.biCompression = fourcc;
 case 'indeo3'
  if 10^6/obj.MainHeader.Fps<1
    error('MATLAB:aviset:fpsInvalidForIndeo3','FPS must be 1 or greater with Indeo3.');
  end
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = 'iv32';
  fourcc = 'iv32';
  obj.Bitmapheader.biCompression = fourcc;
 case 'indeo5'
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = 'iv50';
  fourcc = 'iv50';
  obj.Bitmapheader.biCompression = fourcc;
 case 'msvc'
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = 'msvc';
  fourcc = 'msvc';
  obj.Bitmapheader.biCompression = fourcc;
 otherwise
  if( size(value,2) ~= 4 )
    error(msgID,msg);
  end
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = value;
  obj.Bitmapheader.biCompression = value;
  warning('MATLAB:aviset:compressionUnsupported','Not a supported compression method.  An attempt will be made to use this compressor.');
end
return;

% ------------------------------------------------------------------------
function obj = setQuality(obj,value)

if ~isa(value,'numeric')
  error('MATLAB:aviset:qualityNonNumeric','Quality must be a number.');
end

if obj.MainHeader.TotalFrames ~= 0
  error('MATLAB:aviset:qualitySetLate','Quality must be set before any frames are added.');
end

if (value >= 0) & (value <= 100)
  value = value*100;
  obj.StreamHeader.Quality = value;
else
  error('MATLAB:aviset:qualityOutOfRange','Quality must be in the range of 1 to 100');
end
return;

% ------------------------------------------------------------------------
function obj = setColormap(obj,map)

if obj.MainHeader.TotalFrames ~= 0
  error('MATLAB:aviset:colormapSetLate','The Colormap must be set before any frames are added.');
end

if obj.Bitmapheader.biBitCount  == 24
  error('MATLAB:aviset:colomapTrueColorInvalid','Unable to set colormap for a TrueColor image.');
end

if size(map,1) > 256
  error('MATLAB:aviset:colormapTooLarge','Colormap must no more than 256 entries.');
end

if size(map,2) ~= 3
  error('MATLAB:aviset:colormapInvalidFormat','Colormap must have three columns.');
end

obj.Bitmapheader.biBitCount = 8;
obj.Bitmapheader.biClrUsed = size(map,1);

map = round(map*255);
obj.Bitmapheader.Colormap = uint8([fliplr(map), ...
       zeros(size(map,1),1)]');
return;

% ------------------------------------------------------------------------
function validRequest = isIndeoRequestValid( value )
% ISINDEOREQUESTVALID - check for the existence of the indeo codecs
%    hasIndeo is true if the requested value is an indeo codec 
%    (Indeo5 or Indeo3) AND that codec is available on the machine

if strcmpi(value, 'iv50') || strcmpi(value, 'indeo5')
    % the user is requesting Indeo5 (i.e. 'video 5.1'), see if it is available on this machine
    validRequest = mmcompinfo('video','video 5.1') ~= -1;
elseif strcmpi(value, 'iv32') || strcmpi(value, 'indeo3')
    % the user is requesting Indeo3, see if it is available on this machine
    validRequest = mmcompinfo('video','Intel Indeo(R) Video R3.2') ~= -1;
else
    % the user didn't ask for Indeo so their request is valid
    validRequest = true;
end