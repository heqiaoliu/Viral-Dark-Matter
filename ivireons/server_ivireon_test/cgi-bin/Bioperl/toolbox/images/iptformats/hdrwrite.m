function hdrwrite(hdrImage, filename)
%HDRWRITE   Write Radiance .hdr file.
%    HDRWRITE(HDR, FILENAME) creates a Radiance .hdr file from HDR, a
%    single- or double-precision high dynamic range RGB image.  The .hdr
%    file with the name FILENAME uses run-length encoding to minimize file
%    size. 
%
%    See also HDRREAD, MAKEHDR, TONEMAP.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:22:56 $

iptcheckinput(hdrImage, {'single', 'double'}, ...
    {'finite', 'nonempty', 'nonnan', 'nonnegative', 'nonsparse', 'real'}, ...
    mfilename, 'HDR', 1);

iptcheckinput(filename, {'char'}, {'row'}, mfilename, 'FILENAME', 2);

% Convert the HDR RGB data to RBGE data.
rgbe = rgb2rgbe(permute(hdrImage, [2 1 3]));

% Write the RGBE data to the file.
fid = fopen(filename, 'w');
fprintf(fid, '#?RADIANCE\n');
fprintf(fid, '#Made with MATLAB\n');
fprintf(fid, 'FORMAT=32-bit_rle_rgbe\n');
fprintf(fid, '\n');
fprintf(fid, '-Y %d +X %d\n', size(hdrImage, 1), size(hdrImage, 2));

width = size(hdrImage, 2);

for row = 1:size(hdrImage,1)

    fwrite(fid, [2 2], 'uint8');
    fwrite(fid, width, 'uint16', 'ieee-be');

    for sample = 1:4
        dataStart = (row - 1) * width + 1;
        scanline = rleCoder(rgbe(dataStart:(dataStart + width - 1), sample), width);
        fwrite(fid, scanline, 'uint8');
    end

end
fclose(fid);
