function hdr = makehdr(filenames, varargin)
%MAKEHDR    Create high dynamic range image.
%   HDR = MAKEHDR(FILES) creates the single-precision high dynamic range
%   image HDR from the set of spatially registered low dynamic range
%   images listed in the FILES cell array.  These files must contain
%   EXIF exposure metadata.  The "middle" exposure value between the
%   brightest and darkest images is used as the base exposure for the
%   high dynamic range calculations.  (This value does not need to
%   appear in any particular file.)
%
%   HDR = MAKEHDR(FILES, PARAM1, VALUE1, ...) creates a high dynamic range
%   image from the low dynamic range images in FILES, specifying
%   parameters and corresponding values that control various aspects of
%   the image creation.  Parameter names can be abbreviated and case does
%   not matter.
%
%   Parameters include:
%
%   'BaseFile'          Character array containing the name of the file to
%                       use as the base exposure.
%
%   'ExposureValues'    A vector of exposure values, with one element
%                       for each low dynamic range image in FILES.  An
%                       increase of one exposure value (EV) corresponds
%                       to a doubling of exposure, while a decrease in
%                       one EV corresponds to a halving of exposure.
%                       Any positive value is allowed.  This parameter
%                       overrides EXIF exposure metadata.
%
%   'RelativeExposure'  A vector of relative exposure values, with one
%                       element for each low dynamic range image in
%                       FILES.  An image with a relative exposure (RE)
%                       of 0.5 has half as much exposure as an image
%                       with an RE of 1.  An RE value of 3 has three
%                       times the exposure of an image with an RE of 1.
%                       This parameter overrides EXIF exposure metadata. 
%
%   'MinimumLimit'      A numeric scalar value in the range [0 255] that
%                       specifies the minimum "correctly exposed" value.
%                       For each low dynamic range image, pixels with
%                       smaller values are considered underexposed and
%                       will not contribute to the final high dynamic
%                       range image.
%
%   'MaximumLimit'      A numeric scalar value in the range [0 255] that
%                       specifies the maximum "correctly exposed" value.
%                       For each low dynamic range image, pixels with
%                       larger values are considered overexposed and will
%                       not contribute to the final high dynamic range
%                       image.
%
%   Note: Only one of the 'BaseFile', 'ExposureValues', and
%   'RelativeExposure' parameters may be used at a time.
%
%   Example
%   -------
%
%   Make a high dynamic range image from a series of six low dynamic
%   range images that share the same f/stop number and have different
%   exposure times.  Use TONEMAP to visualize the HDR image.
%
%      files = {'office_1.jpg', 'office_2.jpg', 'office_3.jpg', ...
%               'office_4.jpg', 'office_5.jpg', 'office_6.jpg'};
%      expTimes = [0.0333, 0.1000, 0.3333, 0.6250, 1.3000, 4.0000];
%
%      hdr = makehdr(files, 'RelativeExposure', expTimes ./ expTimes(1));
%      rgb = tonemap(hdr);
%      figure; imshow(rgb)
%
%   Reference: Reinhard, et al. "High Dynamic Range Imaging." 2006. Ch. 4.
%
%   See also HDRREAD, HDRWRITE, TONEMAP.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/02/07 16:30:47 $

% Parse and check inputs.
iptcheckinput(filenames, {'cell'}, {'nonempty'}, mfilename, 'files', 1);
options = parseArgs(varargin{:});
validateOptions(filenames, options);

% Get the minimum exposure image from the user or make a first pass through
% the images to find the lowest exposure image.
if (~isempty(options.basefile))
    [baseTime, baseFStop] = getExposure(options.basefile);
elseif (isempty(options.relexp) && isempty(options.expvals))
    [baseTime, baseFStop] = getAverageExposure(filenames);
end

% Create output variables for an accumulator and the number of LDR images
% that contributed to each pixel.
meta = imfinfo(filenames{1});

[hdr, properlyExposedCount] = makeContainers(meta);

someUnderExposed = false(size(hdr));
someOverExposed = false(size(hdr));
someProperlyExposed = false(size(hdr));

% Construct the HDR image by iterating over the LDR images.
for p = 1:numel(filenames)

    fname = filenames{p};
    
    if (~isempty(options.expvals))
        % Convert log2 EV equivalents to decimal values.
        relExposure = 2 .^ options.expvals(p);
    elseif (~isempty(options.relexp))
        relExposure = options.relexp(p);
    else
		[this_ExposureTime, this_FNumber] = getExposure(fname);
        relExposure = computeRelativeExposure(baseFStop, ...
                                              baseTime, ...
                                              this_FNumber, ...
                                              this_ExposureTime);
    end

    % Read the LDR image
    ldr = loadImage(fname, meta);
    
    underExposed = ldr < options.minclip;
    someUnderExposed = someUnderExposed | underExposed;
    
    overExposed = ldr > options.maxclip;
    someOverExposed = someOverExposed | overExposed;
    
    properlyExposed = ~(underExposed | overExposed);
    someProperlyExposed = someProperlyExposed | properlyExposed;
    
    properlyExposedCount(properlyExposed) = properlyExposedCount(properlyExposed) + 1;
    
    % Remove over- and under-exposed values.
    ldr(~properlyExposed) = 0;
    
    % Bring the intensity of the LDR image into a common HDR domain by
    % "normalizing" using the relative exposure, and then add it to the
    % accumulator.
    hdr = hdr + single(ldr) ./ relExposure;
    
end

% Average the values in the accumulator by the number of LDR images that
% contributed to each pixel to produce the HDR radiance map.
hdr = hdr ./ max(properlyExposedCount, 1);

% For pixels that were completely over-exposed, assign the maximum
% value computed for the properly exposed pixels.
hdr(someOverExposed & ~someUnderExposed & ~someProperlyExposed) = max(hdr(someProperlyExposed));

% For pixels that were completely under-exposed, assign the
% minimum value computed for the properly exposed pixels.
hdr(someUnderExposed & ~someOverExposed & ~someProperlyExposed) = min(hdr(someProperlyExposed));

% For pixels that were sometimes underexposed, sometimes
% overexposed, and never properly exposed, use roifill.
fillMask = imdilate(someUnderExposed & someOverExposed & ~someProperlyExposed, ones(3,3));
if any(fillMask(:))
    hdr(:,:,1) = roifill(hdr(:,:,1), fillMask(:,:,1));
    hdr(:,:,2) = roifill(hdr(:,:,2), fillMask(:,:,2));
    hdr(:,:,3) = roifill(hdr(:,:,3), fillMask(:,:,3));
end

function [baseTime, baseFStop] = getExposure(filename)
% Extract the exposure values from a file containing EXIF metadata.

exif = getExposureDataFromFile(filename);
baseFStop = exif.FNumber;
baseTime = exif.ExposureTime;


function [baseTime, baseFStop] = getAverageExposure(filenames)
% Extract the average exposure (assuming constant illumination) from a set
% of files containing EXIF metadata.  The average exposure may not actually
% correspond to the exposure of any particular image.

minTime = 0;
minFStop = 0;
maxTime = 0;
maxFStop = 0;

% Look through all of the files and keep track of the least and greatest
% exposure.
for p = 1:numel(filenames)

    exif = getExposureDataFromFile(filenames{p});
    
    if (p == 1)
        
        % First file.
        minFStop = exif.FNumber;
        minTime = exif.ExposureTime;
        maxFStop = exif.FNumber;
        maxTime = exif.ExposureTime;
        
    else
        
        % Nth file.
        if (computeRelativeExposure(minFStop, ...
                                    minTime, ...
                                    exif.FNumber, ...
                                    exif.ExposureTime) < 1)

            % Image has least exposure so far.
            minFStop = exif.FNumber;
            minTime = exif.ExposureTime;
            
        elseif (computeRelativeExposure(maxFStop, ...
                                        maxTime, ...
                                        exif.FNumber, ...
                                        exif.ExposureTime) > 1)
            
            % Image has most exposure so far.
            maxFStop = exif.FNumber;
            maxTime = exif.ExposureTime;
            
        end
    
    end
    
end

% Determine the "middle" exposure value.  It's easier to manipulate
% exposure time rather than f/stop.
re = computeRelativeExposure(minFStop, minTime, ...
                             maxFStop, maxTime);
baseFStop = minFStop;
baseTime  = minTime * log2(re);


function exif = getExposureDataFromFile(filename)
% Extract exposure metadata from a file containing EXIF.

try

    meta = imfinfo(filename);
    if isfield(meta, 'DigitalCamera')
        exif = meta.DigitalCamera;
    else

		error('Images:makehdr:exifFormat', ...
			  'File %s does not have EXIF metadata.  %s', ...
			  filename, ...
              'Use the ''ExposureValues'' or ''RelativeExposure'' parameter to provide exposure information.');
 
    end
    
catch ME

    if (isequal(ME.identifier, 'MATLAB:imfinfo:fileOpen'))

        error('Images:makehdr:fileNotFound', ...
              'File %s does not exist.', filename);
          
    else
        
        % Unexpected error.
        rethrow(ME)
        
    end
end

if (isempty(exif) || ...
    ~isstruct(exif) || ...
    ~isfield(exif, 'FNumber') || ...
    ~isfield(exif, 'ExposureTime'))
    
    error('Images:makehdr:noExposureMetadata', ...
          'File %s does not have exposure metadata.  Use the ''ExposureValues'' or ''RelativeExposure'' parameter to provide exposure information.', filename)
      
end



function relExposure = computeRelativeExposure(f1, t1, f2, t2)

% Exposure varies directly with the exposure time and inversely with the
% square of the F-stop number. 
relExposure = (f1 / f2)^2 * (t2 / t1);


function options = parseArgs(varargin)
% Parse the parameter-value pairs, getting default values.

knownParams = {'BaseFile',         'basefile', '', {'char'},    {'vector'};
               'ExposureValues',   'expvals',  [], {'numeric'}, {'vector', 'real', 'finite', 'nonnan'};
               'RelativeExposure', 'relexp',   [], {'numeric'}, {'vector', 'real', 'finite', 'positive', 'nonzero'};
               'MinimumLimit',     'minclip',   5, {'numeric'}, {'scalar', 'integer', 'real', 'nonnan', 'positive'};
               'MaximumLimit',     'maxclip', 250, {'numeric'}, {'scalar', 'integer', 'real', 'nonnan', 'positive'}};
           
options = parseParameterValuePairs(mfilename, knownParams, varargin{:});


function validateOptions(filenames, options)

% Make sure that mutually exclusive options aren't provided.
fieldCount = 0;

if (~isempty(options.basefile))
    fieldCount = fieldCount + 1;
end
if (~isempty(options.expvals))
    fieldCount = fieldCount + 1;
end
if (~isempty(options.relexp))
    fieldCount = fieldCount + 1;
end

if (fieldCount > 1)
    
    error('Images:makehdr:tooManyExposureParameters', ...
          'Only one of the following parameters is allowed: ''BaseFile'', ''ExposureValues'', or ''RelativeExposure''.')
    
end

% Make sure that the correct number of exposure-related values are given.
if (~isempty(options.expvals) && (numel(options.expvals) ~= numel(filenames)))
    
    error('Images:makehdr:wrongExposureValuesCount', ...
          'The number of ''ExposureValues'' elements must match the number of files.')
    
elseif (~isempty(options.relexp) && (numel(options.relexp) ~= numel(filenames)))
    
    error('Images:makehdr:wrongRelativeExposureCount', ...
          'The number of ''RelativeExposure'' elements must match the number of files.')
    
end


function [hdr, counts] = makeContainers(meta)
% Create a floating point accumulator for the final HDR image and a counter
% for the number of contributing images.

if (~isequal(meta.ColorType, 'truecolor'))
    error('Images:makehdr:notRGB', ...
          'Low dynamic range images must be RGB.')
end

hdr = zeros(meta.Height, meta.Width, 3, 'single');
counts = zeros(meta.Height, meta.Width, 3, 'single');


function ldr = loadImage(fname, meta)

ldr = imread(fname);

if (~isequal(size(ldr), [meta.Height, meta.Width, 3]))

    error('Images:makehdr:imageDimensions', ...
        'Low dynamic range image dimensions must agree.  File ''%s'' does not match.', ...
        fname);

end
