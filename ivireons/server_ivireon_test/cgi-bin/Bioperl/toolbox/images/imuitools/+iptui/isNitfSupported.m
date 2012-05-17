function [tf, eid, msg] = isNitfSupported(filename)
%isNitfSupported  Determine if IMTOOL can display NITF file.
%   [TF, EID, MSG] = isNitfSupported(FILENAME) examines the NITF metadata
%   in FILENAME to determine whether IMTOOL, IMSHOW, or RSETWRITE will
%   support it.  TF is true if the file is usable by those tools, and EID
%   and MSG will be empty.  Otherwise, TF is false, EID contains a
%   suitable error ID, and MSG contains a descriptive message about why
%   the NITF file is not usable.

%   Copyright 2009 The MathWorks, Inc.  
%   $Revision: 1.1.6.1 $  $Date: 2009/03/09 19:15:58 $


[nitfFormat, nitfVer] = isnitf(filename);

% Make sure the file is in the NITF format before continuing.
if (~nitfFormat)
    
    tf = false;
    eid = 'Images:%s:notNitf';
    msg = 'The file is not in the NITF format';
    return
    
end

% NITF files must have a version of at least 2.0.
nitfVerFloat = sscanf(nitfVer, '%f');
if (isempty(nitfVerFloat) || ...
    (nitfVerFloat < 2.0))
    
    tf = false;
    eid = 'Images:%s:nitfVersion';
    msg = sprintf('The NITF file version is not supported. (version = %s)', nitfVer);
    return
    
end

% Determine suitability for display functions by examining the file
% metadata.
meta = nitfinfo(filename);

if (meta.NumberOfImages < 1)
    
    tf = false;
    eid = 'Images:%s:nitfNoImages';
    msg = 'The NITF file does not contain any images.';
    
elseif (~strncmpi(meta.ImageSubheaderMetadata.ImageSubheader001.ImageCompression, ...
                  'NC', 2) && ...
        ~strncmpi(meta.ImageSubheaderMetadata.ImageSubheader001.ImageCompression, ...
                  'NM', 2))
    
    tf = false;
    eid = 'Images:%s:nitfCompressed';
    msg = 'Compressed imagery in NITF files is not supported.';
    
elseif (isequal(meta.ImageSubheaderMetadata.ImageSubheader001.PixelValueType, 'R'))
    
    tf = false;
    eid = 'Images:%s:nitfSingle';
    msg = 'Floating point data in NITF files is not supported.';
    
elseif (~isequal(meta.ImageSubheaderMetadata.ImageSubheader001.PixelValueType, 'INT') && ...
        (computeNumberOfNitfBands(meta) > 1))

    tf = false;
    eid = 'Images:%s:nitfRgbType';
    msg = 'Images with more than one sample must have unsigned integer data.';
    
elseif (computeNumberOfNitfBands(meta) > 3)

    tf = false;
    eid = 'Images:%s:nitfNumberOfBands';
    msg = 'Too many bands in image.';
    
else

    % Success.
    tf = true;
    eid = '';
    msg = '';
    
end


function numBands = computeNumberOfNitfBands(meta)

if (isfield(meta.ImageSubheaderMetadata.ImageSubheader001, ...
            'NumberOfMultiSpectralBands'))
    
    numBands = meta.ImageSubheaderMetadata.ImageSubheader001.NumberOfMultiSpectralBands;

else
    
    numBands = meta.ImageSubheaderMetadata.ImageSubheader001.NumberOfBands;
    
end
