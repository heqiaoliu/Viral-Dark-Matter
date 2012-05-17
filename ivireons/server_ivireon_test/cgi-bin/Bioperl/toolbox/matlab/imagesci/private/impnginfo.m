function info = impnginfo(filename)
%IMPNGNFO Information about a PNG file.
%   INFO = IMPNGINFO(FILENAME) returns a structure containing
%   information about the PNG file specified by the string
%   FILENAME.  
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, August 1996
%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/07/28 14:29:17 $

try
    info = png('info',filename);
    s = dir(filename);
    info.FileModDate = s.date;
    info.FileSize = s.bytes;
catch myException
    error('MATLAB:impnginfo:pnginfo', myException.message);
end

