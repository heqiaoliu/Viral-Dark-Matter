function data = hdrread(filename)
%HDRREAD    Read Radiance HDR image.
%   HDR = HDRREAD(FILENAME) reads the high dynamic range image HDR from
%   FILENAME, which points to a Radiance .hdr file.  HDR is an m-by-n-by-3
%   RGB array in the range [0,inf) and has type single.  For scene-referred
%   datasets, these values usually are scene illumination in radiance
%   units.  To display these images, use an appropriate tone-mapping
%   operator.
%
%   Class Support
%   -------------
%   The output image HDR is an m-by-n-by-3 image with type single.
%
%   Example
%   -------
%       hdr = hdrread('office.hdr');
%       rgb = tonemap(hdr);
%       imshow(rgb);
%
%   Reference: "Radiance File Formats" by Greg Ward Larson
%   (http://radsite.lbl.gov/radiance/refer/filefmts.pdf)
%
%   See also HDRWRITE, MAKEHDR, TONEMAP.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/01/15 18:53:35 $

fid = openFile(filename);
fileinfo = readHeader(fid);
data = readImage(fid, fileinfo);



function fid = openFile(filename)
%openFile   Open a file.

iptcheckinput(filename, {'char'}, {'row'}, mfilename, 'FILENAME', 1);

[fid, msg] = fopen(filename, 'r');
if (fid == -1)
    
    error('images:hdrread:fileOpen', ...
          'Unable to open file "%s" for reading: %s.', filename, msg);
    
end



function fileInfo = readHeader(fid)
%readHeader   Extract key HDR values from the text header.

header = '';

% Ensure that we're reading an HDR file.
while (isempty(strfind(header, '#?')) && ~feof(fid))
    header = fgetl(fid);
    continue;
end

radianceMarker = strfind(header, '#?');
if (isempty(radianceMarker))
    fclose(fid);
    error('images:hdrread:notRadiance', 'Not a Radiance file.')
end

fileInfo.identifier = header((radianceMarker+1):end);
if (isempty(strfind(fileInfo.identifier, 'RADIANCE')) && ...
    isempty(strfind(fileInfo.identifier, 'RGBE')))
    
    fclose(fid);
    error('images:hdrread:noMarker', 'No Radiance file marker.')
end

% Use fgetl, which strip newlines and to find the transition between
% header and data.
headerLine = fgetl(fid);
while (~isempty(headerLine))
    headerLine = fgetl(fid);
end

% Read the resolution variables.  This is the number and length of scanlines.
headerLine = fgetl(fid);
fileInfo.Ysign = headerLine(1);
[fileInfo.height, count, errmsg, nextindex] = sscanf(headerLine(4:end), '%d', 1);
fileInfo.Xsign = headerLine(nextindex+4);
fileInfo.width = sscanf(headerLine(nextindex+7:end), '%d', 1);



function img = readImage(fid, fileInfo)
%readImage   Get the decoded RGB data from the file.

% The file pointer (fid) should be at the start of the image data.

% Allocate space for the output.
img(fileInfo.height, fileInfo.width, 3) = single(0);

% Read the remaining data
encodedData = fread(fid, inf, 'uint8=>uint8');
fclose(fid);

scanlineWidth = fileInfo.width;
scanlineCount = fileInfo.height;

if ((scanlineWidth < 8) || (scanlineWidth > 32767))
    % The scanline width precludes run-length encoding.  Simply treat all
    % of the data as RGBE.
    img = reshape(encodedData, [scanlineWidth, scanlineCount, 4]);
    return;
end

% Create a buffer for the uncompressed data.
decodedData(scanlineWidth, 4) = uint8(0);

% Set the data pointer to the beginning of the compressed data.
offset = 1;

% Process each scanline.
for scanline = 1:scanlineCount

    % "New format" RLE scanlines encode the RGBE components separately.
    % These scanlines start with [2 2].
    if ((encodedData(offset) ~= 2) || ...
        (encodedData(offset+1) ~= 2))
        
        error('images:hdrread:unsupportedRLE', ...
              'This file uses an unsupported run-length encoding method.');
        
    end
    
    % The next two bytes represent the scanline width.
    if (getScanlineLength(encodedData((2:3) + offset)) ~= scanlineWidth)

        error('images:hdrread:scanlineWidth', ...
              'The scanline length does not match the image width.')
        
    end
    
    offset = offset + 4;
    
    for sample = 1:4
        
        % Decode the portion of the scanline for the current sample.  When
        % determining how much of the encoded scanline to send, assume the
        % worst possible compression (1:2).
         stopIdx = min(numel(encodedData), offset + 2*scanlineWidth);
         
         [decodedData(:, sample), numDecodedBytes] = ...
             rleDecoder(encodedData(offset:stopIdx), scanlineWidth);
         offset = offset + numDecodedBytes;
         
    end
    
    % Convert the UINT8 buffer to floating point and add it to the output.
    img(scanline,:,:) = rgbe2rgb(decodedData);
    
end



function scanlineLength = getScanlineLength(rawData)
%getScanlineLength   Determine the length of a scanline.

% Scanline length is a two-byte, big-endian word.
scanlineLength = double(rawData(1)) * 256 + ...
                 double(rawData(2));
return
