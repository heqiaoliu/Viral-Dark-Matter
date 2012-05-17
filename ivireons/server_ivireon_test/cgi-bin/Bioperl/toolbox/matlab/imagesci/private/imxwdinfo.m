function info = imxwdinfo(filename)
%IMXWDINFO Get information about the image in an XWD file.
%   INFO = IMXWDINFO(FILENAME) returns information about
%   the image contained in an XWD file.  
%
%   See also IMREAD, IMWRITE, and IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/03/27 19:14:58 $

%   Reference:  Murray and vanRyper, Encyclopedia of Graphics
%   File Formats, 2nd ed, O'Reilly, 1996.

fid = fopen(filename, 'r', 'ieee-be');
if (fid == -1)
    error('MATLAB:imxwdinfo:fileOpen', ...
          'Unable to open file "%s" for reading.', filename);
end

% Initialize the standard fields to fix the order.
info = initializeMetadataStruct('xwd', fid);

info.FormatSignature = [];

% The file may be written as big-endian or little-endian.
% If the second uint value we read is not 7, re-open the file as
% little-endian.
info.FormatSignature = fread(fid, 2, 'uint32');
if (length(info.FormatSignature) < 2)
    fclose(fid);
    error('MATLAB:imxwdinfo:truncatedHeader', ...
              'Truncated header');
end

info.HeaderSize = info.FormatSignature(1);
info.FormatVersion = info.FormatSignature(2);
if (info.FormatVersion ~= 7)
    fclose(fid);
    fid = fopen(filename, 'r', 'ieee-le');
    if (fid == -1)
        error('MATLAB:imxwdinfo:fileOpen', ...
          'Unable to open file "%s" for reading.', filename);
    end
    info.FormatSignature = fread(fid, 2, 'uint32');
    info.HeaderSize = info.FormatSignature(1);
    info.FormatVersion = info.FormatSignature(2);
    if (info.FormatVersion ~= 7)
        fclose(fid);
        error('MATLAB:imxwdinfo:XWDVersion', ...
              'Not an X11 XWD file');
    end
end

format = fread(fid, 1, 'uint32');
if (isempty(format))
   fclose(fid);
   error('MATLAB:imxwdinfo:truncatedHeader', ...
         'Truncated header');
end

switch format
case 0
    info.PixmapFormat = 'XYBitmap';
case 1
    info.PixmapFormat = 'XYPixmap';
case 2
    info.PixmapFormat = 'ZPixmap';
otherwise
    info.PixmapFormat = 'unknown';
end
info.PixmapDepth = fread(fid, 1, 'uint32');
info.Width = fread(fid, 1, 'uint32');
info.Height = fread(fid, 1, 'uint32');
info.XOffset = fread(fid, 1, 'uint32');
info.ByteOrder = fread(fid, 1, 'uint32');
info.BitmapUnit = fread(fid, 1, 'uint32');
info.BitmapBitOrder = fread(fid, 1, 'uint32');
info.BitmapPad = fread(fid, 1, 'uint32');
info.BitDepth = fread(fid, 1, 'uint32');
info.BytesPerLine = fread(fid, 1, 'uint32');
info.VisualClass = fread(fid, 1, 'uint32');
info.RedMask = fread(fid, 1, 'uint32');
info.GreenMask = fread(fid, 1, 'uint32');
info.BlueMask = fread(fid, 1, 'uint32');
info.BitsPerRgb = fread(fid, 1, 'uint32');
info.NumberOfColors = fread(fid, 1, 'uint32');
info.NumColormapEntries = fread(fid, 1, 'uint32');
info.WindowWidth = fread(fid, 1, 'uint32');
info.WindowHeight = fread(fid, 1, 'uint32');
info.WindowX = fread(fid, 1, 'int32');
info.WindowY = fread(fid, 1, 'int32');
info.WindowBorderWidth = fread(fid, 1, 'uint32');
info.Name = char(fread(fid, info.HeaderSize - ftell(fid), 'uint8')');

if (isempty(info.NumColormapEntries))
    fclose(fid);
    error('MATLAB:imxwdinfo:truncatedHeader', ...
          'Truncated header');
end

if (info.NumColormapEntries > 0)
    info.ColorType = 'indexed';
    
else
    if (isempty(info.BitDepth))
       fclose(fid);
       error('MATLAB:imxwdinfo:truncatedHeader', ...
          'Truncated header');
    end

    if (info.BitDepth <= 8)
        info.ColorType = 'grayscale';
    else
        info.ColorType = 'truecolor';
    end
end

fclose(fid);
