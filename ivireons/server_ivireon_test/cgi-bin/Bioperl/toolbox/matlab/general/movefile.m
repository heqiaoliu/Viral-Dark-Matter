%MOVEFILE Move file or directory.
%   [SUCCESS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION,MODE) moves the
%   file or directory SOURCE to the new file or directory DESTINATION. Both
%   SOURCE and DESTINATION may be either an absolute pathname or a pathname
%   relative to the current directory. When MODE is used, MOVEFILE moves SOURCE
%   to DESTINATION, even when DESTINATION is read-only. The DESTINATION's
%   writable attribute state is preserved. See NOTE 1.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE)  moves the source to the
%   current directory. See NOTE 2.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION) attempts to move
%   SOURCE to DESTINATION. If SOURCE ends in the wildcard *, all matching file
%   objects are moved to DESTINATION (see NOTE 3). If DESTINATION is a directory,
%   MOVEFILE moves SOURCE under DESTINATION. If SOURCE is a directory and 
%   DESTINATION does not exist, MOVEFILE creates DESTINATION as a
%   directory and moves the contents of SOURCE under DESTINATION, effectively 
%   renaming SOURCE. If SOURCE is a single file and DESTINATION is not a 
%   directory or does not exist, SOURCE is effectively renamed to
%   DESTINATION.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION,'f') attempts to
%   move SOURCE to DESTINATION, as above, even if DESTINATION is read-only. The
%   status of the writable attribute of DESTINATION will be preserved.
%
%   INPUT PARAMETERS:
%       SOURCE:      1 x n string defining the source file or directory. See NOTE 4.
%       DESTINATION: 1 x n string defining destination file or directory. See
%                    NOTE 4.
%       MODE:        character scalar defining copy mode.
%                    'f' : force SOURCE to be written to DESTINATION. See NOTE 5.
%                    If omitted, MOVEFILE respects the current writable status
%                    of DESTINATION.
%
%   RETURN PARAMETERS:
%       SUCCESS:     logical scalar, defining the outcome of MOVEFILE.
%                    1 : MOVEFILE executed successfully.
%                    0 : an error occurred.
%       MESSAGE:     string, defining the error or warning message.
%                    empty string : MOVEFILE executed successfully.
%                    message : an error or warning message, as applicable.
%       MESSAGEID:   string, defining the error or warning identifier.
%                    empty string : MOVEFILE executed successfully.
%                    message id: the MATLAB error or warning message identifier
%                    (see ERROR, MException, WARNING, LASTWARN).
%
%   NOTE 1: Except where otherwise stated, the rules of the underlying operating
%           system on the preservation of attributes are followed when moving
%           files and directories.
%   NOTE 2: MOVEFILE cannot move a file onto itself.
%   NOTE 3: MOVEFILE cannot move multiple files onto one file.
%   NOTE 4: UNC paths are supported. The * wildcard, as a suffix to the last name
%           or the extension to the last name in a path string, is supported.
%   NOTE 5: 'writable' is being deprecated, but still supported for backwards
%           compatibility.
%
%   See also CD, COPYFILE, DELETE, DIR, FILEATTRIB, MKDIR, RMDIR.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.14 $ $Date: 2009/09/28 20:25:31 $

%   Package: libmwbuiltins
%   Built-in function.
