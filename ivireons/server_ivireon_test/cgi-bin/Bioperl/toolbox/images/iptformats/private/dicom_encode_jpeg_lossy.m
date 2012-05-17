function [fragments, frames] = dicom_encode_jpeg_lossy(X)
%DICOM_ENCODE_JPEG_LOSSY   Encode pixel cells using lossy JPEG compression.
%   [FRAGMENTS, LIST] = DICOM_ENCODE_JPEG_LOSSY(X) compresses and encodes
%   the image X using baseline lossy JPEG compression.  FRAGMENTS is a
%   cell array containing the encoded frames (as UINT8 data) from the
%   compressor.  LIST is a vector of indices to the first fragment of
%   each compressed frame of a multiframe image.
%
%   See also DICOM_ENCODE_RLE.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/11/24 14:58:52 $


% Use IMWRITE to create a JPEG image, but don't warn about signed data.
origWarning = warning;
warning('off', 'MATLAB:imwrite:signedPixelData');

tempfile = tempname;
imwrite(X, tempfile, 'jpeg');

warning(origWarning);

% Read the image from the temporary file.
fid = fopen(tempfile, 'r');
fragments{1} = fread(fid, inf, 'uint8=>uint8');
fclose(fid);

frames = 1;

% Remove the temporary file.
try
    delete(tempfile)
catch
    
    warning('Images:dicom_encode_jpeg_lossy:tempFileDelete',...
    'Unable to delete temporary file "%s".', tempfile);
end
