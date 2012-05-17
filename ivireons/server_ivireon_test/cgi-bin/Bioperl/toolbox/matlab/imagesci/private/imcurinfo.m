function info = imcurinfo(filename)
%IMICURINFO Get information about the image in a CUR file.
%   INFO = IMCURINFO(FILENAME) returns information about
%   the image contained in a CUR file containing one or more
%   Microsoft Windows cursor resources.  
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/03/27 19:14:44 $

[fid, msg] = fopen(filename, 'r', 'ieee-le');  % CUR files are little-endian
if (fid == -1)
    error('MATLAB:imcurinfo:fileOpen', ...
          'Unable to open file "%s" for reading: %s.', filename, msg);
end

% Initialize universal structure fields to fix the order
info = initializeMetadataStruct('cur', fid);

% Initialize CUR-specific structure fields to fix the order
info.FormatSignature = [];
info.NumColormapEntries = [];
info.Colormap = [];

% Read the resource header to verify the correct type
sig = fread(fid, 2, 'uint16');
if (isempty(sig))
    fclose(fid);
    error('MATLAB:imcurinfo:fileEmpty', ...
          'File %s is empty', filename);
end
    
if (~isequal(sig, [0; 2]))
    fclose(fid);
    error('MATLAB:imcurinfo:notCURFile', ...
          'File %s is not a CUR file', filename);
end

% Find the number of cursors in the file
imcount = fread(fid, 1, 'uint16');

for p = 1:imcount
    info(p).Filename = info(1).Filename;
    info(p).FileModDate = info(1).FileModDate;
    info(p).FileSize = info(1).FileSize;
    info(p).Format = 'cur';
    info(p).FormatSignature = sig';

    % Offset to the current cursor directory entry
    cdpos = 6 + 16*(p - 1);
    fseek(fid, cdpos, 'bof');
    
    % Read the cursor directory
    info(p).Width = fread(fid, 1, 'uint8');
    info(p).Height = fread(fid, 1, 'uint8');
    
    fseek(fid, 2, 'cof');

    info(p).HotSpot(1,1) = fread(fid, 1, 'uint16') + 1;  % zero-based
    info(p).HotSpot(1,2) = fread(fid, 1, 'uint16') + 1;  % zero-based

    info(p).ResourceSize = fread(fid, 1, 'uint32');
    info(p).ResourceDataOffset = fread(fid, 1, 'uint32');

    % Start reading bitmap header info
    fseek(fid, info(p).ResourceDataOffset, 'bof');
    
    info(p).BitmapHeaderSize = fread(fid, 1, 'uint32');

    fseek(fid, 8, 'cof');
    
    info(p).NumPlanes = fread(fid, 1, 'uint16');
    info(p).BitDepth = fread(fid, 1, 'uint16');
    
    fseek(fid, 4, 'cof');

    info(p).BitmapSize = fread(fid, 1, 'uint32');

    % Headers must be at least 40 bytes, but they may be larger.
    % Skip ahead to the beginning of the colormap data.
    info(p).ColormapOffset = info(p).ResourceDataOffset + ...
        info(p).BitmapHeaderSize;
    
    fseek(fid, info(p).ColormapOffset, 'bof');
    
    % Read the RGBQUAD colormap: [blue green red reserved]
    info(p).NumColormapEntries = info(p).NumPlanes * ...
        2^(info(p).BitDepth);

    [data, count] = fread(fid, (info(p).NumColormapEntries)*4, 'uint8');
    
    if (count ~= info(p).NumColormapEntries*4)
        fclose(fid);
        error('MATLAB:imcurinfo:truncatedColormap', ...
              'Truncated colormap data');
    end

    % Throw away the reserved byte, swap red and blue, and rescale
    data = reshape(data, 4, info(p).NumColormapEntries)';
    cmap = data(:,1:3);
    cmap = fliplr(cmap);
    cmap = cmap ./ 255;
    
    info(p).Colormap = cmap;

    info(p).ColorType = 'indexed';
    info(p).CompressionType = 'none';
    info(p).ImageDataOffset = ftell(fid);
    
    % Other validity checks
    if ((info(p).Width < 0) || (info(p).Height < 0))
        fclose(fid);
        error('MATLAB:imcurinfo:badImageDimensions', ...
          'Corrupt CUR file: bad image dimensions');
    end
end

fclose(fid);
