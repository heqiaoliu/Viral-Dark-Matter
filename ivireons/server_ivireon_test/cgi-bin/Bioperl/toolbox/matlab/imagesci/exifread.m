function output = exifread(imagefile)
%EXIFREAD will be removed in a future release. Please use IMFINFO instead.

%   OUTPUT = EXIFREAD(IMAGEFILE) reads the EXIF image metadata from
%   the file specified by the string IMAGEFILE. IMAGEFILE should be
%   a JPEG or TIFF image file.  OUTPUT is a structure containing
%   metadata values about the image or images in IMAGEFILE.  This
%   function returns all EXIF tags and does not process them in any
%   way. 
%
%   For more information on EXIF and the meaning of metadata
%   attributes, see <http://www.exif.org/>.
%  
%   See also IMREAD, IMFINFO

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/09/28 20:25:42 $

% deprecation warning 
warning('MATLAB:exifread:DeprecatedFunction', ...
        ['EXIFREAD will be removed in a future release.'...
        'Please use IMFINFO instead.']);

% Ensure the file exists.
if (~ischar(imagefile))
    error('MATLAB:exifread:filenameMustBeChar', ...
        'Filename must be a character array.')
end

fid = fopen(imagefile);
if (fid == -1)
    error('MATLAB:exifread:fileNotFound', ...
        'File was not found or could not be read.')
else
    % Get the full path to the file if it isn't in the current directory.
    imagefile = fopen(fid);
    fclose(fid);
end

% Call exif_info.mex with information about the file type.
if isjpg(imagefile) 
    output = exif_info(imagefile, 1);
    
elseif istif(imagefile)
    output = exif_info(imagefile, 2);
    
else
    error('MATLAB:exifread:UnsupportedFormat',...
        'EXIF data not supported in this file format');
    
end

% check whether we need to convert UserNote from unicode to native 
if isfield(output, 'UserComment')
    if length(output.UserComment)>8 
        if double(output.UserComment(1:8)) == hex2dec(['55' '4E' '49' '43' '4F' '44' '45' '63'])
            output.UserComment = unicode2native(output.UserComment(9:end));
        else
            output.UserComment = output.UserComment(9:end);
        end
    end
end

