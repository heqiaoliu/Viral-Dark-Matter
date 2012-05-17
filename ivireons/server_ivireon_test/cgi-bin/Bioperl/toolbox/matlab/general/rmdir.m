%RMDIR Remove directory.
%   RMDIR(DIRECTORY) removes DIRECTORY from the parent directory, subject
%   to access rights. DIRECTORY must be empty.
%
%   RMDIR(DIRECTORY, 's') removes DIRECTORY, including the subdirectory 
%   tree, from the parent directory. See NOTE 1.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY) removes DIRECTORY from 
%   parent directory, returning status and error information as described
%   below under Return Parameters.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY,MODE) removes DIRECTORY from
%   the parent directory, subject to access rights. RMDIR can remove
%   subdirectories recursively.
%
%   INPUT PARAMETERS:
%       DIRECTORY: string specifying a directory, relative or absolute.
%                  See NOTE 2.
%       MODE:      character scalar indicating the mode of operation.
%                  's': indicates that the subdirectory tree, implied by DIRECTORY,
%                  will be removed recursively.
%
%   RETURN PARAMETERS:
%       SUCCESS:   logical scalar, defining the outcome of RMDIR.
%                  1 : RMDIR executed successfully.
%                  0 : an error occurred.
%       MESSAGE:   string, defining the error or warning message.
%                  empty string : RMDIR executed successfully.
%                  message : an error or warning message, as applicable.
%       MESSAGEID: string, defining the error or warning identifier.
%                  empty string : RMDIR executed successfully.
%                  message id: the MATLAB error or warning message identifier
%                  (see ERROR, MException, WARNING, LASTWARN).
%
%   NOTE 1: MATLAB removes the subdirectory tree regardless of the write
%           attribute of any contained file or subdirectory.
%   NOTE 2: UNC paths are supported. RMDIR does not support the wildcard *.
%
%   See also CD, COPYFILE, DELETE, DIR, FILEATTRIB, MKDIR, MOVEFILE.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.14 $ $Date: 2009/03/30 23:40:07 $

%   Package: libmwbuiltins
%   Built-in function.
