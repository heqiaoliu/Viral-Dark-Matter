function X = nitfread( filename, varargin ) 
%NITFREAD Read NITF image
%   X = NITFREAD(FILENAME) reads the first image from the NITF 2.0 or 2.1
%   file in the character array FILENAME, which must be in the current
%   directory, in a directory on the MATLAB path, or contain the full
%   path to the file.
%
%   X = NITFREAD(FILENAME, IDX) reads the image with index number IDX
%   from an NITF file that contains multiple images.
%
%   X = NITFREAD(..., 'PixelRegion', {ROWS, COLS}) reads a region of
%   pixels from a NITF image.  ROWS and COLS are two or three element
%   vectors, where the first value is the start location, and the last
%   value is the ending location.  In the three value syntax, the second
%   value is the increment.
%
%   This function supports version 2.0 and 2.1 NITF files, as well as NSIF
%   1.0.  Compressed images, image submasks, and NITF 1.1 files are not
%   supported.
%   
%   See also ISNITF, NITFINFO.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/07/06 20:35:38 $


% Parse input arguments.
iptchecknargin(1, 4, nargin, mfilename)

args = parseArgs(varargin{:});

if (isempty(args.pixelregion))
    
    region = [];
    
else
    
    region = processRegion(args.pixelregion);
    
end

nitfMeta = nitfinfo(filename); % NITFINFO will check the file and the version

% Make sure there is an image in the file.
if (nitfMeta.NumberOfImages == 0)

    warning('Images:nitfread:noImage', ...
            'There are no images in this file.')
    X = [];
    return
    
end
    
checkImageNumber(nitfMeta, args.index);
    
% Given the image number, generate the accessor for the specific image
% subheader
subheader = getImageSubheaderMetadata(nitfMeta, args.index);

% Calculate offset to specified image data set
offsetStart = getOffsets(nitfMeta, args.index);

% Get the size of the pixels
pixelType = getPixelType(subheader);

% Get the image.
X = readImage(subheader, pixelType, ...
              nitfMeta.Filename, offsetStart, region); 



function checkImageNumber(nitfMeta, imageNumber)
% Check to make sure that there is an image corresponding to the image number.

iptcheckinput(imageNumber, {'numeric'}, {'positive'}, mfilename, 'IDX', 2)

if (imageNumber > nitfMeta.NumberOfImages)

    error('Images:nitfread:badImageNumber', ...
          'There is no image corresponding to: "%d".', imageNumber)

end



function subheaderLengthsStruct = getSubheaderLengths(nitfMeta, imageNumber)
subheaderLengthsStruct = nitfMeta.ImageAndImageSubheaderLengths.(sprintf('Image%03dImageAndSubheaderLengths', imageNumber));

    
    
function subheader = getImageSubheaderMetadata(nitfMeta, imageNumber)
subheader = nitfMeta.ImageSubheaderMetadata.(sprintf('ImageSubheader%03d', imageNumber));

    

function checkIntegers(inputValue)

if (~isnumeric(inputValue) || ...
    any((rem(inputValue, 1) ~= 0) & ~(isinf(inputValue))) || ...
    any(inputValue < 1))
    
    error('Images:nitfread:invalidPixelRegion', ...
          'The pixel region cell array must contain positive integers.');

end



function args = parseArgs(varargin)
%PARSEARGS  Convert input arguments to structure of arguments.

args.index = 1;
args.pixelregion = [];

if (isempty(varargin))
    return
end

% Handle the index argument, which is not part of a P-V pair.
p = 1;
if (isnumeric(varargin{1}))
    
    args.index = varargin{1};
    p = p + 1;
    
elseif (~ischar(varargin{1}))
    
    error('Images:nitfread:badSecondArgument', ...
          'Second argument must be an image number or parameter name.')
    
end

% Handle the rest of the P-V pairs.
params = {'pixelregion'};

while (p <= nargin)
   
    if (ischar(varargin{p}))
        
        idx = strmatch(lower(varargin{p}), params);
        
        if (isempty(idx))
            error('Images:nitfread:unknownParam', ...
                  'Unknown parameter ''%s''.', varargin{p})
        elseif (numel(idx) > 1)
            error('Images:nitfread:ambiguousParam', ...
                  'Ambiguous parameter ''%s''.', varargin{p})
        end
        
        if (p == nargin)
            error('Images:nitfread:missingValue', ...
                  'Missing value for parameter ''%s''.', varargin{p})
        end
        
        args.(params{idx}) = varargin{p + 1};
        p = p + 2;
        
    else
        
        error('Images:nitfread:invalidParamName', ...
              'Parameter names must be character arrays.')
        
    end
            
end



function regionStruct = processRegion(regionCell)
%PROCESSREGION  Convert a cells of pixel region info to a struct.

regionStruct = struct([]);

if ((~iscell(regionCell)) || (numel(regionCell) ~= 2))
    error('Images:nitfread:pixelRegionCell', ...
          'PixelRegion must be a two element cell array.')
end

for p = 1:numel(regionCell)
    
    checkIntegers(regionCell{p});
    
    if (numel(regionCell{p}) == 2)
        
        start = max(0, regionCell{p}(1) - 1);
        incr = 1;
        stop = regionCell{p}(2) - 1;
        
    elseif (numel(regionCell{p}) == 3)
        
        % Value 1: start
        start = max(0, regionCell{p}(1) - 1);
        
        % Value 2: increment/stride
        incr = regionCell{p}(2);
        if (isinf(incr))
            error('Images:nitfread:infIncrement', ...
                  'The pixel region increment must be finite.');
        end
 
        % Value 3: stop
        stop = regionCell{p}(3) - 1;
       
    else
        
        error('Images:nitfread:tooManyPixelRegionParts', ...
              'PixelRegion values must contain [START, STOP] or [START, INCR, STOP].');
        
    end
        
    if (start > stop)
        error('Images:nitfread:badPixelRegionStartStop', ...
              'Stop value must be greater than start value.')
    end
    
    regionStruct(p).start = start;
    regionStruct(p).incr = incr;
    regionStruct(p).stop = stop;

end



function offsetStart = getOffsets(nitfMeta, imageNumber)
% Calculate the offset of an image from the beginning of the file using
% the metadata.

headerLength = nitfMeta.NITFFileHeaderLength;

subheaderLengthsStruct = getSubheaderLengths(nitfMeta, imageNumber);

% Add the length of the main header and the subheaders up to the
% desired image
offsetStart = imageNumber * subheaderLengthsStruct.LengthOfNthImageSubheader + ...
    (imageNumber-1) * subheaderLengthsStruct.LengthOfNthImage + ...
    headerLength;

% Remove the size of the Image Data Mask Table (if present) from the size
% of the image.
sizeOfDataMaskTable = computeSizeOfDataMaskTable(nitfMeta, imageNumber);
offsetStart = offsetStart + sizeOfDataMaskTable;


    
function pixelType = getPixelType(subheader)
% Returns the sample format of each pixel.

PixelValueType = subheader.PixelValueType;

switch (PixelValueType)
case {'INT', 'B'} % Integer, Bi-level
    pixelType = 1;

case('SI') % Two's complement signed integer
    pixelType = 2;

case('R') % Real
    pixelType = 3;

case('C') % Complex
    pixelType = 6;

otherwise
    error('Images:nitfread:getPixelType', ...
          'Unrecognized pixel value type: %s.', PixelValueType)
        
end



function X = readImage(subheader, pixelType, filename, offsetStart, region) 

checkCompression(subheader);

imageHeight = subheader.NumberOfSignificantRowsInImage;
imageWidth = subheader.NumberOfSignificantColumnsInImage;
tileHeight = subheader.NumberOfPixelsPerBlockVertical;
tileWidth = subheader.NumberOfPixelsPerBlockHorizontal;

if (tileWidth == 0)
    tileWidth = imageWidth;
end

if (tileHeight == 0)
    tileHeight = imageHeight;
end

%Prepare a struct to support pixel processing by rnitfc.
details.filename = filename;
details.imageWidth = imageWidth;
details.imageHeight = imageHeight;
details.samplesPerPixel = getNumberOfBands(subheader);
details.bitsPerSample = subheader.NumberOfBitsPerPixelPerBand;
details.planarConfiguration = subheader.ImageMode;
details.offsetStart = offsetStart;
details.tileWidth = tileWidth;
details.tileHeight = tileHeight;
details.pixelType = pixelType;

%Call the rnitfc C routine passing just the metadata structure

if (isempty(region))
    
    myPixels = rnitfc(details);
    
else
    
    myPixels = rnitfc(details, region);
    
end

% All NITF files are written big endian.  But it appears that pixels
% which don't end on byte boundaries are written a byte at a time.
[c, m, endian] = computer;
if (isequal(endian, 'L'))
    
    % Swap images from IEEE-BE to IEEE-LE if needed.
    if ((details.bitsPerSample == 16) || ...
        (details.bitsPerSample == 32) || ...
        (details.bitsPerSample == 64))
        
        X = swapbytes(myPixels);
        
    else
        
        X = myPixels;
        
    end
    
else
    
    X = myPixels;
    
end



function sizeOfDataMaskTable = computeSizeOfDataMaskTable(nitfMeta, imageNumber)

subheader = nitfMeta.ImageSubheaderMetadata.(sprintf('ImageSubheader%03d', imageNumber));

if (isfield(subheader, 'BlockedImageDataOffset'))
    sizeOfDataMaskTable = subheader.BlockedImageDataOffset;
else
    sizeOfDataMaskTable = 0;
end



function NBands = getNumberOfBands(subheader)

%Number of Bands
if (subheader.NumberOfBands > 0)

    NBands =  subheader.NumberOfBands;

elseif (subheader.NumberOfBands == 0) && (subheader.NumberOfMultiSpectralBands > 0)

    NBands = subheader.NumberOfMultiSpectralBands;

else 

    error('Images:nitfread:ZeroBandsNotSupported', ...
          'Could not resolve number of bands in image.');

end



function checkCompression(subheader)

% Possible values for Image Compression:
% * NC -> Not Compressed
% * NM -> Not Compressed but has a block mask and/or a transparent pixel mask
% * C1 -> bi-level
% * C3 -> JPEG
% * C4 -> Vector Quantization
% * C5 -> Lossless JPEG
% * I1 -> Downsampled JPEG
% * M1, M3, M4, M5 -> JPEG containing a mask

ImageCompression = subheader.ImageCompression;

if (~strcmp(ImageCompression, 'NC') && ~strcmp(ImageCompression, 'NM'))
    error('Images:nitfread:compressed', ...
          'Compressed images currently not supported.')
end
