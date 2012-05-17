function [isUrl, filenameOut] = getFileFromURL(filenameIn)
%GETFILEFROMURL Detects whether the input filename is a URL and downloads
%file from the URL

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/27 19:14:42 $

% Download remote file.
if (strfind(filenameIn, '://'))
  
    isUrl = true;

    if (~usejava('jvm'))
        error('MATLAB:getFileFromURL:noJVM', ...
              'Reading from a URL requires a Java Virtual Machine.')
    end
    
    try
        filenameOut = urlwrite(filenameIn, tempname);
    catch
        error('MATLAB:getFileFromURL:urlRead', ...
              'Can''t read URL "%s".', filenameIn);
    end
    
else
  
    isUrl = false;
    filenameOut = filenameIn;
    
end