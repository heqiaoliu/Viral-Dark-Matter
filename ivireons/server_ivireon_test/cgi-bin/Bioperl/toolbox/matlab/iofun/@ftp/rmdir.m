function rmdir(h,dirname)
%rmdir Remove a directory on an FTP site.
%    RMDIR(FTP,DIRECTORY) removes a directory on an FTP site.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2007 The MathWorks, Inc.
% $Revision: 1.1.4.2 $  $Date: 2007/11/07 18:43:04 $

% Make sure we're still connected.
connect(h)

status = h.jobject.removeDirectory(dirname);
if (status == 0)
    code = h.jobject.getReplyCode;
    switch code
        case 550
            error('MATLAB:ftp:DeleteFailed','Could not remove "%s" on the server.',dirname);
        otherwise
            error('MATLAB:ftp:FtpError','FTP error %.0f.',code)
    end
end