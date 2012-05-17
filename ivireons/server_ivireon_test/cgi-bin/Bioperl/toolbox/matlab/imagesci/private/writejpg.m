function writejpg(data, map, filename, varargin)
%WRITEJPG Write a JPG file to disk.
%   WRITEJPG(I,[],FILENAME) writes the grayscale image I
%   to the file specified by the string FILENAME.
%
%   WRITEJPG(RGB,[],FILENAME) writes the truecolor image
%   represented by the M-by-N-by-3 array RGB.
%
%   WRITEJPG(X,MAP,FILENAME) writes the indexed image X with
%   colormap MAP.  The resulting file will contain the equivalent
%   truecolor image.
%
%   WRITEJPG(...,'quality',VAL) uses VAL as the quality
%   factor.  VAL should be a scalar in the range [0, 100];
%   its default is 75.
%
%   WRITEJPG(...,'comment',COMMENTS) uses COMMENTS as the
%   column vector cell array or char matrix of comments to be
%   written to the file.  Each row in COMMENTS is written as a
%   separate comment.
%
%   WRITEJPG(...,'bitdepth',DEPTH) specifies the number of bits
%   that will be written for each sample.  DEPTH must be 8, 12,
%   or 16.  The default value of DEPTH is 8.
%
%   WRITEJPG(...,'mode',VAL) uses VAL as the compression mode.
%   MODE must be either 'lossy' for (8 or 12 bit depths) or 
%   'lossless' (for 8, 12, or 16 bits).  The default value of
%   MODE is 'lossy'.
  
%   Steven L. Eddins, August 1996
%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/05/14 22:02:54 $

  
% Input checking.
if (ndims(data) > 3)
    error('MATLAB:writejpg:tooManyDims', ...
          '%d-D data not supported for JPEG files', ndims(data));
end

if (~isempty(map) && ndims(data)>2)
    error('MATLAB:writejpg:tooManyDimsForIndexed', ...
          '%d-D indexed image data not supported for JPEG files', ndims(data));
end

ncomp = size(data,3);
if ((ncomp ~= 1) && (ncomp ~= 3))
    error('MATLAB:writejpg:wrongNumberOfComponents', ...
          'Data with %d components not supported for JPEG files', ncomp);
end

props = set_jpeg_props(data,varargin{:});



%
% The default bits property may be too restrictive



if ((props.bits > 12) && (ncomp > 1))
    error('MATLAB:writejpg:tooManyBitsForColor', ...
          'Only grayscale images supported with %d bit data.', props.bits)
end

if ((props.bits > 12) && (isequal(props.mode, 'lossy')))
    error('MATLAB:writejpg:tooManyBitsForLossy', ...
          'Lossy compression not supported for %d bit data.', props.bits)
end

maxval = (2 ^ (props.bits)) - 1;

% Convert indexed images to RGB, clipping out-of-bounds values.
if (~isempty(map))

    switch (class(data))
    case {'double', 'single'}
      
        data = uint8(data - 1);
     
    otherwise
    
        data(data < 0) = 0;
        
    end
    
    data = ind2rgb(data, map);
    
end


% Convert image data to UINT8/UINT16, if necessary.
if islogical(data)
  
    % Convert binary images to grayscale.
    mask = data;
    
    if (props.bits <= 8)
        data = uint8(data);
    else
        data = uint16(data);
    end
    
    data(mask) = maxval;
    
elseif ((~isa(data, 'uint8')) && (props.bits <= 8))
  
    % Convert 8-bit or smaller non-UINT8 samples to [0, maxval].
    data = uint8(maxval * double(data));
   
elseif ((props.bits > 8) && (isa(data, 'double')))
  
    % Scale double data.
    data = uint16(maxval * double(data));
    
elseif ((props.bits > 8) && (~isa(data, 'uint16')))
  
    % Don't scale if bits are greater than 8 for nondouble.
    % Do store all >8 bit/sample as UINT16.
    data = uint16(data);
    
end


% Write data to JPEG file.
if (props.bits <= 8)
  
    wjpg8c(data, filename, props);
    
elseif (props.bits <= 12)
  
    wjpg12c(data, filename, props);
    
else
  
    wjpg16c(data, filename, props);
    
end










function props = set_jpeg_props(data,varargin)
% SET_JPEG_PROPS
%
% Parse input parameters to produce a properties structure.  
%


%
% Set the default properties.
props.bits = 8;
props.quality = 75;
props.comment = {};

%
% UINT16 requires that the mode be lossless.  The user can try to 
% specify lossy anyway, but it will throw an exception.
if isa(data,'uint16')
    props.mode = 'lossless';
else
    props.mode = 'lossy';
end


% Process param/value pairs
paramStrings = {'quality'
                'comment'
                'bitdepth'
                'mode'};


for k = 1:2:length(varargin)
  
    param = lower(varargin{k});
    if (~ischar(param))
        error('MATLAB:writejpg:badParameterName', ...
              'Parameter name must be a string');
    end
    
    idx = strmatch(param, paramStrings);
    if (isempty(idx))
        error('MATLAB:writejpg:unrecognizedParameter', ...
              'Unrecognized parameter name "%s"', param);
    elseif (length(idx) > 1)
        error('MATLAB:writejpg:ambiguousParameter', ...
              'Ambiguous parameter name "%s"', param);
    end

    param = deblank(paramStrings{idx});

    props = process_argument_value ( props, param, varargin{k+1} );
    
    
end


%
% Special case for UINT16 data.  If handed UINT16 data, then the bitdepth
% has to be 12 or 16.  This requires the user to put forth the effort of 
% actually specifying this (we don't do it for them).
if ( isa(data,'uint16') && (~((props.bits == 16) || (props.bits ==12))) )
    error('MATLAB:writejpg:bitdepthNotSpecifiedAt16', ...
          'UINT16 image data requires bitdepth specifically set to either 12 or 16.');
end





% Process a parameter name/value pair, return the new property structure
function output_props = process_argument_value ( props, param_name, param_value )

output_props = props;

switch param_name 
case 'quality'
  
    quality = param_value;
    
    if (~isa(quality,'numeric'))
        error('MATLAB:writejpg:badQualityValue', ...
              '''Quality'' value must be numeric')
    end
    
    if ((quality < 0) || (quality > 100))
        error('MATLAB:writejpg:badQualityValue', ...
              'Invalid value for ''Quality''');
    end
    
    output_props.quality = quality;
    
case 'comment'
  
    comment = param_value;
    
    if (~ischar(comment) && ~iscellstr(comment))
        error('MATLAB:writejpg:badCommentValue', ...
              ['''Comment'' value must be a column vector cell array of' ...
             ' strings or a char matrix']);
    end
    
    % Convert the char matrix to a cell array
    output_props.comment = cellstr(comment);
    
case 'bitdepth'

    bits = param_value;
    
    if (~isa(bits,'numeric'))
        error('MATLAB:writejpg:badBitDepth', ...
            '''BitDepth'' value must be numeric');
    end
    
    if (~any(bits == [8 12 16]))
        error('MATLAB:writejpg:badBitDepth', ...
              '''BitDepth'' value must be 8, 12, or 16');
    end

    output_props.bits = bits;

case 'mode'
    
    mode = lower(param_value);
    
    if ((~ischar(mode)) || ...
        ((~isequal(mode, 'lossy')) && (~isequal(mode, 'lossless'))))
      
        error('MATLAB:writejpg:badMode', ...
              '''Mode'' must be ''Lossy'' or ''Lossless''')
    
    end
    
    output_props.mode = mode;
 
end

return
