function [X,map] = readtif(filename, varargin)
%READTIF Read an image from a TIFF file.
%   [X,MAP] = READTIF(FILENAME) reads the first image from the
%   TIFF file specified by the string variable FILENAME.  X will
%   be a 2-D uint8 array if the specified data set contains an
%   8-bit image.  It will be an M-by-N-by-3 uint8 array if the
%   specified data set contains a 24-bit image.  MAP contains the
%   colormap if present; otherwise it is empty. 
%
%   [X,MAP] = READTIF(FILENAME, N, ...) reads the Nth image from the
%   file.
%
%   READTIF accepts trailing parameter-value pairs.  The parameter names and
%   corresponding values are:
%
%       Parameter Name        Value
%       --------------        -----
%       Index                 Scalar; same as input parameter N above
%
%       Info                  Struct; same as input parameter INFO above
%
%       PixelRegion           {ROWS, COLS}
%                             reads a region of pixels from the file. ROWS
%                             and COLS are two- or three-element vectors,
%                             where the first value is the start location,
%                             and the last value is the ending location. In
%                             the three-value syntax, the second value is the
%                             increment.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.10 $  $Date: 2009/11/09 16:27:35 $

args = parse_args(varargin{:});
checkIndex(args.index)
args.filename = filename;
args.pixelregion = process_region(args.pixelregion);

if ~isempty(args.info) && isfield(args.info, 'Offset')
    % If INFO input is provided, use the Offset field to determine where the
    % specified image is located in the file.
    
    if args.index > numel(args.info)
        error('MATLAB:readtif:indexInfoMismatch', ...
                'Image index greater than the number of elements in the info struct.');
    end

    args.offset = args.info(args.index).Offset;
end

[X, map, details] = rtifc(args);

map = double(map)/65535;

if (details.Photo == 8)
    % TIFF image is in CIELAB format.  Issue a warning that we're
    % converting the data to ICCLAB format, and correct the a* and b*
    % values.
    
    % First, though, check to make sure we have the expected number of
    % samples per pixel.
    if (size(X,3) ~= 1) && (size(X,3) ~= 3)
        eid = 'MATLAB:imread:unexpectedCIELabSamplesPerPixel';
        msg = 'Unexpected number of samples per pixel for CIELab image.';
        error(eid,msg);
    end

	% Now check that we have uint8 or uint16 data.
	if ~ (isa(X,'uint8') || isa(X,'uint16'))
		error('MATLAB:readtif:wrongCieLabDatatype', ...
		      'CIELab images must have a datatype of either uint8 or uint16 instead of %s.', ...
			  class(X) );
	end
    
    wid = 'MATLAB:imread:CielabConversion';
    msg = 'Converting CIELab-encoded TIFF image to ICCLab encoding.';
    warning(wid,msg);
    
    X = cielab2icclab(X);
end



function args = parse_args(varargin)
%PARSE_ARGS  Convert input arguments to structure of arguments.

args.index = 1;
args.pixelregion = [];
args.info = [];

params = {'index', 'pixelregion', 'info'};

p = 1;
while (p <= nargin)
    
    argp = varargin{p};
    if (isnumeric(argp))

        args.index = argp;
        p = p + 1;
        
    elseif (ischar(argp))
        
        idx = find(strncmpi(argp, params, numel(argp)));
        
        if (isempty(idx))
            error('MATLAB:readtif:unknownParam', ...
                  'Unknown parameter ''%s''.', argp)
        elseif (numel(idx) > 1)
            error('MATLAB:readtif:ambiguousParam', ...
                  'Ambiguous parameter ''%s''.', argp)
        end
        
        if (p == nargin)
            error('MATLAB:readtif:missingValue', ...
                  'Missing value for parameter ''%s''.', argp)
        end
        
        args.(params{idx}) = varargin{p + 1};
        p = p + 2;
        
    else
        
        error('MATLAB:readtif:paramType', ...
              'Parameter names must be character arrays.')
        
    end
            
end

check_info(args.info);

function check_info(info)
%CHECK_INFO Issue error message if user passed in invalid info struct.

if isempty(info)
    return
end

if ~all(isfield(info, {'Filename', 'FileModDate', 'FileSize', ...
                       'Format', 'FormatVersion', 'Width', ...
                       'Height', 'BitDepth', 'ColorType', ...
                       'FormatSignature'}))
    error('MATLAB:readtif:invalidInfoStruct', ...
          'Invalid ''Info'' parameter; should be the output of IMFINFO.');
end


function region_struct = process_region(region_cell)
%PROCESS_PIXELREGION  Convert a cells of pixel region info to a struct.

region_struct = struct([]);
if isempty(region_cell)
    % Not specified in call to readtif.
    return;
end

if ((~iscell(region_cell)) || (numel(region_cell) ~= 2))
    error('MATLAB:readtif:pixelRegionCell', ...
          'PixelRegion must be a two element cell array.')
end

for p = 1:numel(region_cell)
    
    checkIntegers(region_cell{p});
    
    if (numel(region_cell{p}) == 2)
        
        start = max(0, region_cell{p}(1) - 1);
        incr = 1;
        stop = region_cell{p}(2) - 1;
        
    elseif (numel(region_cell{p}) == 3)
        
        start = max(0, region_cell{p}(1) - 1);
        
        if (~isinf(region_cell{p}(2)))
            incr = region_cell{p}(2);
        else
            error('MATLAB:readtif:infIncrement', ...
                  'The pixel region increment must be finite.');
        end
        
        stop = region_cell{p}(3) - 1;
       
    else
        
        error('MATLAB:readtif:tooManyPixelRegionParts', ...
              'PixelRegion values must contain [START, STOP] or [START, INCR, STOP].');
        
    end
        
    if (start > stop)
        error('MATLAB:readtif:badPixelRegionStartStop', ...
              'Stop value must be greater than start value.')
    end

    if (incr < 1)
        error('MATLAB:readtif:badPixelRegionIncrement', ...
              'Pixel region increment must be a positive integer.')
    end

    region_struct(p).start = start;
    region_struct(p).incr = incr;
    region_struct(p).stop = stop;

end


function checkIntegers(inputValue)

if (~isnumeric(inputValue) || ...
    any((rem(inputValue, 1) ~= 0) & ~(isinf(inputValue))) || ...
    any(inputValue < 0))
    
    error('MATLAB:readtif:regionPartNotNumeric', ...
          'The pixel region cell array must contain positive integers.');

end


function checkIndex(inputIndex)

if (~isPositiveFiniteIntegerScalar(inputIndex))
    
    error('MATLAB:readtif:badIndex', ...
          'The image index must be a positive, finite, integer scalar.')

end


function tf = isPositiveFiniteIntegerScalar(values)

tf = isnumeric(values) && ...
     all(rem(values, 1) == 0) && ...
     all(~isinf(values)) && ...
     all(values > 0) && ...
     (numel(values) == 1);
