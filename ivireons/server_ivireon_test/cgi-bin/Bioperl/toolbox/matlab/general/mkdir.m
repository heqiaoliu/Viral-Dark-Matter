%MKDIR Make new directory.
%   [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR) makes a new
%   directory, NEWDIR, under the parent, PARENTDIR. While PARENTDIR may be
%   an absolute path, NEWDIR must be a relative path. When NEWDIR exists,
%   MKDIR returns SUCCESS = 1.  If the number of output arguments is 1 or
%   less, it also issues a warning that the directory already exists.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(NEWDIR) creates the directory
%   NEWDIR in the current directory, if NEWDIR represents a relative path.
%   Otherwise, NEWDIR represents an absolute path and MKDIR attempts to
%   create the absolute directory NEWDIR in the root of the current volume.
%   An absolute path starts in any one of a Windows drive letter, a UNC
%   path '\\' string or a UNIX '/' character. 
%
%   INPUT PARAMETERS:
%       PARENTDIR: string specifying the parent directory. See NOTE 1.
%       NEWDIR:    string specifying the new directory. 
%
%   RETURN PARAMETERS:
%       SUCCESS:   logical scalar, defining the outcome of MKDIR. 
%                  1 : MKDIR executed successfully. 0 : an error occurred.
%       MESSAGE:   string, defining the error or warning message. 
%                  empty string : MKDIR executed successfully. message :
%                  an error or warning message, as applicable.
%       MESSAGEID: string, defining the error or warning identifier.
%                  empty string : MKDIR executed successfully. message id:
%                  the MATLAB error or warning message identifier (see
%                  ERROR, MException, WARNING, LASTWARN).
%
%   NOTE 1: UNC paths are supported. 
%
%   See also CD, COPYFILE, DELETE, DIR, FILEATTRIB, MOVEFILE, RMDIR.

%   Copyright 1984-2009 The MathWorks, Inc. $Revision: 1.37.4.11 $
%   $Date: 2009/03/30 23:40:01 $

%   Package: libmwbuiltins Built-in function.
