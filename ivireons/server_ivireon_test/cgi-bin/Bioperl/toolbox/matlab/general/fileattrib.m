%FILEATTRIB    Set or get attributes of files and directories.
%   [SUCCESS,MESSAGE,MESSAGEID] = FILEATTRIB(FILE,MODE,USERS,MODIFIER) sets the
%   attributes of FILE, in similar fashion as ATTRIB for DOS or CHMOD for UNIX
%   and LINUX. Several attributes, delimited by spaces, may be specified at
%   once. FILE may point at a file or directory and may contain an absolute
%   pathname or a pathname relative to the current directory. 
%
%   [SUCCESS,MESSAGE,MESSAGEID] = FILEATTRIB  gets, according to the field
%   definitions of MESSAGE, the attributes of the current directory itself. See
%   RETURN PARAMETERS. See NOTE 1. 
%
%   INPUT PARAMETERS:
%       FILE:      1 x n string, defining the file or directory. See NOTE 2.
%       MODE:      space-delimited string, defining the mode of the file or
%                  directory. See NOTE 3. 
%                  'a' : archive (Windows/DOS only).
%                  'h' : hidden file (Windows/DOS only).
%                  's' : system file (Windows/DOS only).
%                  'w' : write access.
%                  'x' : executable (UNIX only).
%                  Either '+' or '-' must be added in front of each file mode to set
%                  or clear an attribute. 
%       USERS:     space-delimited string, defining which users are
%                  affected by the attribute setting. (UNIX only)
%                  'a' : all users. 
%                  'g' : group of users.
%                  'o' : other users.
%                  'u' : current user.
%                  Default attribute is dependent upon the UNIX umask.
%       MODIFIER:  character scalar, modifying the behavior of FILEATTRIB. 
%                  's' : operate recursively on files and directories in the
%                        directory subtree. See NOTE 4.
%                        Default - MODIFIER is absent or the empty string.
%
%   RETURN PARAMETERS:
%       SUCCESS:   logical scalar, defining the outcome of FILEATTRIB.
%                  1 : FILEATTRIB executed successfully.
%                  0 : an error occurred. 
%       MESSAGE:   structure array; when requesting attributes, defines file
%                  attributes in terms of the following fields (see NOTE 5):
%
%            Name: string vector containing name of file or directory
%         archive: 0 or 1 or NaN 
%          system: 0 or 1 or NaN 
%          hidden: 0 or 1 or NaN 
%       directory: 0 or 1 or NaN 
%        UserRead: 0 or 1 or NaN 
%       UserWrite: 0 or 1 or NaN 
%     UserExecute: 0 or 1 or NaN 
%       GroupRead: 0 or 1 or NaN 
%      GroupWrite: 0 or 1 or NaN 
%    GroupExecute: 0 or 1 or NaN 
%       OtherRead: 0 or 1 or NaN 
%      OtherWrite: 0 or 1 or NaN 
%    OtherExecute: 0 or 1 or NaN 
%
%       MESSAGE:   string, defining the error or warning message.
%                  empty string : FILEATTRIB executed successfully.
%                  message : error or warning message, as applicable.
%       MESSAGEID: string, defining the error or warning identifier.
%                  empty string : FILEATTRIB executed successfully.
%                  message id: error or warning message identifier.
%                  (see ERROR, Mexception, WARNING, LASTWARN).
%
%   EXAMPLES:
%
%   fileattrib mydir\*  recursively displays the attributes of 'mydir'
%   and its contents. 
%
%   fileattrib myfile -w -s  sets the 'read-only' attribute and revokes
%   the 'system file' attribute of 'myfile'. 
%
%   fileattrib 'mydir' -x  revokes the 'executable' attribute of 'mydir'.
%
%   fileattrib mydir '-w -h'  sets read-only and revokes hidden attributes
%   of 'mydir'. 
%
%   fileattrib mydir -w a s  revokes, for all users, the 'writable'
%   attribute from 'mydir' as well as its subdirectory tree.
%
%   fileattrib mydir +w '' s  sets 'mydir', as well as its subdirectory tree,
%   writable. 
%
%   fileattrib myfile '+w +x' 'o g'  sets the 'writable' and 'executable'
%   attributes of 'myfile' for other users as well as group.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = fileattrib('mydir\*'); if successful,
%   returns the success status 1 in SUCCESS, the attributes of 'mydir' and its
%   subdirectory tree in the structure array MESSAGE. If a warning was issued,
%   MESSAGE contains the warning, while MESSAGEID contains the warning message
%   identifier. In case of failure, SUCCESS contains success status 0, MESSAGE
%   contains the error message, and MESSAGEID contains the error message
%   identifier. 
%
%   [SUCCESS,MESSAGE,MESSAGEID] = fileattrib('myfile','+w +x','o g') sets the
%   'writable' and 'executable' attributes of 'myfile' for other users as well
%   as group. 
%
%
%   NOTE 1: When FILEATTRIB is called without return arguments and an error
%           has occurred while executing FILEATTRIB, the error message is
%           displayed.
%   NOTE 2: UNC paths are supported. The * wildcard, as a suffix to the last
%           name or the extension  to the last name in a path string, is
%           supported.
%   NOTE 3: Operating system specific attribute modifiers apply; therefore
%           specifying invalid modifiers will result in error messages.
%   NOTE 4: On Windows 2000 and later: equivalent to ATTRIB switches /s /d. 
%   NOTE 5: Attribute field values are type logical. NaN indicates that an
%           attribute is not defined for a particular operating system. 
%
%   See also CD, COPYFILE, DELETE, DIR, MKDIR, MOVEFILE, RMDIR.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.15.4.13 $ $Date: 2009/03/30 23:39:59 $

%   Package: libmwbuiltins
%   Built-in function.
