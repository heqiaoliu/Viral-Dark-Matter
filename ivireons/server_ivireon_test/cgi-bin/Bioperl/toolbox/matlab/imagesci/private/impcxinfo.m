function info = impcxinfo(filename)
%IMPCXINFO Get information about the image in a PCX file.
%   INFO = IMPCXINFO(FILENAME) returns information about
%   the image contained in a PCX file.  
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/03/27 19:14:52 $

[fid, msg] = fopen(filename, 'r', 'ieee-le');
if (fid == -1)
    error('MATLAB:impcxinfo:fileOpen', ...
          'Unable to open file "%s" for reading: %s.', filename, msg);
end

% Initialize universal structure fields to fix the order
info = initializeMetadataStruct('pcx', fid);
info.FormatSignature = [];

if (fseek(fid, 128, 'bof') ~= 0)
    fclose(fid);
    error('MATLAB:impcxinfo:notPCXFile', ...
          'File %s is not a PCX file', filename);
end

fseek(fid, 0, 'bof');

info.FormatSignature = fread(fid, 2, 'uint8');
if (info.FormatSignature(1) ~= 10)
    fclose(fid);
    error('MATLAB:impcxinfo:notPCXFile', ...
          'File %s is not a PCX file', filename);
end

info.FormatVersion = info.FormatSignature(2);
if (~ismember(info.FormatVersion, [0 2 3 4 5]))
    fclose(fid);
    error('MATLAB:impcxinfo:unrecognizedPCXFormat', ...
          'Unrecognized or unsupported PCX format version');
end

encoding = fread(fid, 1, 'uint8');
if (encoding == 1)
    info.Encoding = 'RLE';
else
    info.Encoding = 'unknown';
end

info.BitsPerPixelPerPlane = fread(fid, 1, 'uint8');
info.XStart = fread(fid, 1, 'uint16');
info.YStart = fread(fid, 1, 'uint16');
info.XEnd = fread(fid, 1, 'uint16');
info.YEnd = fread(fid, 1, 'uint16');
info.HorzResolution = fread(fid, 1, 'uint16');
info.VertResolution = fread(fid, 1, 'uint16');
info.EGAPalette = fread(fid, 48, 'uint8');
info.Reserved1 = fread(fid, 1, 'uint8');
info.NumColorPlanes = fread(fid, 1, 'uint8');
info.BytesPerLine = fread(fid, 1, 'uint16');
info.PaletteType = fread(fid, 1, 'uint16');
info.HorzScreenSize = fread(fid, 1, 'uint16');
info.VertScreenSize = fread(fid, 1, 'uint16');

info.Width = info.XEnd - info.XStart + 1;
info.Height = info.YEnd - info.YStart + 1;
info.BitDepth = info.NumColorPlanes * info.BitsPerPixelPerPlane;
if (info.BitDepth == 24)
    info.ColorType = 'truecolor';

else
    % There might not be a colormap at the end of the file.  We
    % don't want to find out in this function because it requires
    % seeking to the end-of-file, which takes too much time for
    % big image files.   In fact, to be absolutely sure we would
    % have to decode the image.  But most PCX files that are
    % 8-bit or less are indexed.
    info.ColorType = 'indexed';
    
end


fclose(fid);
