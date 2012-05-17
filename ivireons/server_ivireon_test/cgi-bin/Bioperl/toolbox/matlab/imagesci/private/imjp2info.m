function metadata = imjp2info(filename)
%IMJP2NFO Information about a JPEG 200 file.
%   METADATA = IMJP2INFO(FILENAME) returns a structure containing
%   information about the JPEG 2000 file specified by the string
%   FILENAME.  
%
%   See also IMFINFO.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/03 05:24:29 $

% JPEG2000 is not supported on Solaris.	 
if (isequal(computer(), 'SOL64'))	 
    error('MATLAB:imjp2info:unsupportedPlatform', ...	 
          'JPEG2000 is not supported on Solaris.')	 
end	 

% Call the interface to the Kakadu library.
metadata = imjp2infoc(filename);

d = dir(filename);
metadata.Filename = filename;
metadata.FileModDate = d.date;
metadata.FileSize = d.bytes;

