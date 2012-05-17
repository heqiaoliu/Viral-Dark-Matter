function [A, map] = readjp2(filename, varargin)
%READJP2 Read image data from JPEG 2000 files.
%   A = READJP2(FILENAME) reads image data from a JPEG file.
%   A is a 2-D grayscale or 3-D RGB image whose type depends on the
%   bit-depth of the image (logical, uint8, uint16, int8, int16).
%
%   See also IMREAD.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/03/04 16:29:50 $

% Error if anything other than a filename was passed.

% Check input arguments
options = parse_args(varargin{:});
if (~isNonnegativeFiniteIntegerScalar(options.reductionlevel))    
    error('MATLAB:readjp2:badReductionLevel', ...
          'The reduction level must be a non-negative, finite, integer scalar.')
end
options.pixelregion = process_region(options.pixelregion);
if ~isa(options.v79compatible, 'logical')
    error('MATLAB:readjp2:badV79Compatible', ...
          'V79Compatible value must be logical.')
end

% JPEG2000 is not supported on Solaris.
if (isequal(computer(), 'SOL64'))
    error('MATLAB:readjp2:unsupportedPlatform', ...
          'JPEG2000 is not supported on Solaris.')
end

% Setup default options.
options.useResilientMode = false;  % default is fast mode

% Call the interface to the Kakadu library.
try
	A = readjp2c(filename,options);

catch firstException
	
	switch firstException.identifier
		case 'MATLAB:jp2adapter:libraryError:ephMarkerNotFollowingPacketHeader'

		    % Try resilient mode.  
			options.useResilientMode = true;
			try
				A = readjp2c(filename,options);

				% Ok we succeeded.  Issue a warning to the user that their
				% file might have some problems.  
				warning(firstException.identifier,...
				        'The image was successfully read from %s, but the following problem was reported:\n\n%s', ...
						filename, firstException.message );

			catch secondException
				% Ok it's hopeless, just give up.
				rethrow(firstException);	
			end

		otherwise
			% We don't know what to try.  Give up.
			rethrow(firstException);	
	end


end
map = [];

function args = parse_args(varargin)
%PARSE_ARGS  Convert input arguments to structure of arguments.

args.reductionlevel = 0;
args.pixelregion = [];
args.v79compatible = false;

params = {'reductionlevel', 'pixelregion', 'v79compatible'};

p = 1;
while (p <= nargin)
    
    argp = varargin{p};
    if (ischar(argp))
        
        idx = find(strncmpi(argp, params, numel(argp)));
        
        if (isempty(idx))
            error('MATLAB:readjp2:unknownParam', ...
                  'Unknown parameter ''%s''.', argp)
        elseif (numel(idx) > 1)
            error('MATLAB:readjp2:ambiguousParam', ...
                  'Ambiguous parameter ''%s''.', argp)
        end
        
        if (p == nargin)
            error('MATLAB:readjp2:missingValue', ...
                  'Missing value for parameter ''%s''.', argp)
        end
        
        args.(params{idx}) = varargin{p + 1};
        p = p + 2;
        
    else
        
        error('MATLAB:readjp2:paramType', ...
              'Parameter names must be character arrays.')
        
    end
            
end


function region_struct = process_region(region_cell)
%PROCESS_PIXELREGION  Convert a cells of pixel region info to a struct.

region_struct = struct([]);
if isempty(region_cell)
    % Not specified in call to readjp2.
    return;
end

if ((~iscell(region_cell)) || (numel(region_cell) ~= 2))
    error('MATLAB:readjp2:pixelRegionCell', ...
          'PixelRegion must be a two element cell array.')
end

for p = 1:numel(region_cell)
    
    checkIntegers(region_cell{p});
    
    if (numel(region_cell{p}) == 2)
        
        start = max(0, region_cell{p}(1) - 1);
        stop = region_cell{p}(2) - 1;
        
    else
        
        error('MATLAB:readjp2:tooManyPixelRegionParts', ...
              'PixelRegion values must contain [START, STOP].');
        
    end
        
    if (start > stop)
        error('MATLAB:readjp2:badPixelRegionStartStop', ...
              'Stop value must be greater than start value.')
    end

    region_struct(p).start = start;
    region_struct(p).stop = stop;

end


function checkIntegers(inputValue)

if (~isnumeric(inputValue) || ...
    any((rem(inputValue, 1) ~= 0) & ~(isinf(inputValue))) || ...
    any(inputValue <= 0))
    
    error('MATLAB:readjp2:regionPartNotNumeric', ...
          'The pixel region cell array must contain positive integers.');

end


function tf = isNonnegativeFiniteIntegerScalar(values)

tf = isnumeric(values) && ...
     all(rem(values, 1) == 0) && ...
     all(~isinf(values)) && ...
     all(values >= 0) && ...
     (numel(values) == 1);

