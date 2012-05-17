function deleteDownload(filename)
%DELETEDOWNLOAD Deletes the temporary file downloaded from the URL

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/27 19:14:41 $

try
    delete(filename);
catch
    warning('MATLAB:deleteDownload:removeTempFile', ...
            'Can''t delete temporary file "%s".', filename)
end
