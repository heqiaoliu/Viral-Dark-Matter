function info = imjpginfo(filename)
%IMJPGINFO Information about a JPEG file.
%   INFO = IMJPGINFO(FILENAME) returns a structure containing
%   information about the JPEG file specified by the string
%   FILENAME.  
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, August 1996
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/09/28 20:27:23 $

% JPEG files are big-endian.  Open the file and look at the first
% 2 bytes.  If they are not [255 216], then we don't have a JFIF
% or raw JPEG file and we can bail out without calling the
% MEX-file.
[fid, msg] = fopen(filename, 'r', 'ieee-be');
if (fid == -1)
    error('MATLAB:imjpginfo:fileOpen', ...
          'Unable to open file "%s" for reading: %s.', filename, msg);
end

filename = fopen(fid);
d = dir(filename);
sig = fread(fid, 2, 'uint8');
fclose(fid);
if (~isequal(sig, [255; 216]))
    error('MATLAB:imjpginfo:notJPGFile', ...
          'File %s is not a JPEG file', filename);
end

[depth, m] = jpeg_depth(filename);

if (isempty(depth))
    error('MATLAB:imjpginfo:emptyDepth', m);              
end

if (depth <= 8)
    info = imjpg8(filename);
elseif (depth <= 12)
    info = imjpg12(filename);
else
    info = imjpg16(filename);
end

info.FileModDate = d.date;
info.FileSize = d.bytes;

if (info.NumberOfSamples == 1)
    info.ColorType = 'grayscale';
else
    info.ColorType = 'truecolor';
end

switch (info.CodingMethod)
    case 0
        method = 'Huffman';
    case 1
        method = 'Arithmetic';
end

info.CodingMethod = method;

switch (info.CodingProcess)
    case 0
        process = 'Sequential';
    case 1
        process = 'Progressive';
    case 2
        process = 'Lossless';
end

info.CodingProcess = process;


%
% We use try/catch here because tiff tags are really optional,
% unlike the case with TIFF.
try
	raw_tags = tifftagsread ( filename );
	info = incorporate_exif_metadata(raw_tags, info );
catch me
    warning(me.identifier,'%s',me.message);
	return
end




%==============================================================================
function info = incorporate_exif_metadata(raw_tags,info)
%info contains meta data read by the imjpg mex files and this file
%raw_tags contains the Exif metadata. If the jpg file contains an Exif
%Thumbnail, raw_tags is an array of structures.

processed_tags = tifftagsprocess ( raw_tags );
if isempty(processed_tags)
    return;
end

%Merge Exif meta data from first IFD (main image) into info
tagnames = fieldnames(raw_tags);
for j = 1:numel(tagnames)
    
    %
    % The following fields are not often correctly provided via
    % the TIFF tags.  The jpeg mex-files do these for us.
    switch ( tagnames{j} )
        case { 'Filename', 'FileModDate', 'FileSize', 'Format', ...
                'FormatVersion', 'Width', 'Height', 'BitDepth', ...
                'ColorType', 'FormatSignature' }
            continue;
    end
    
    %If this image has a thumbnail, and that thumbnail has a tag not
    %present in the main image, it will turn up as an [] value. Skip it.
    if(length(processed_tags)>1 ...
            && isempty(processed_tags(1).(tagnames{j}))... %main image
            && ~isempty(processed_tags(2).(tagnames{j})) ) %thumbnail
        continue;                                          %skip it
    end
    
    info.(tagnames{j}) = processed_tags(1).(tagnames{j});
end

if(length(processed_tags)>1)
    %Hang Exif meta data of thumbnail (second IFD) off info
    info.ExifThumbnail = processed_tags(2:end);
end

