%IMPORT Adds to the current packages and classes import list.
%   IMPORT PACKAGE_NAME.* adds the specified package name to the
%   current import list.   
%
%   IMPORT PACKAGE1.* PACKAGE2.* ... adds multiple package names.
%
%   IMPORT CLASSNAME adds the fully qualified class name to the
%   import list.
%
%   IMPORT CLASSNAME1 CLASSNAME2 ... adds multiple fully qualified class 
%   names.
%
%   IMPORT PACKAGE_NAME.FUNCTION adds the specified package-based function
%   to the current import list.
%
%   Use the functional form of IMPORT, such as IMPORT(S), when the
%   package or class name is stored in a string.
%
%   L = IMPORT(...) returns as a cell array of strings the contents
%   of the current import list as it exists when IMPORT completes.
%   L = IMPORT, with no inputs, returns the current import list
%   without adding to it.
%
%   IMPORT affects only the import list of the function within which
%   it is used.  There is also a base import list that is used
%   at the command prompt.  If IMPORT is used in a script, it will
%   affect the import list of the function which invoked the script,
%   or the base import list if the script is invoked from the
%   command prompt.
%
%   CLEAR IMPORT clears the base import list.  The import lists of
%   functions may not be cleared.
%
%   Examples:
%   %Example 1: add the meta package of the MATLAB class system to 
%   %the current import list
%       import meta.*
%
%   %Example 2: add java.awt package to the current import list
%       import java.awt.*
%       f = Frame;               % Create java.awt.Frame object
%
%   %Example 3: import two java packages 
%       import java.util.Enumeration java.lang.*
%       s = String('hello');     % Create java.lang.String object
%       methods Enumeration      % List java.util.Enumeration methods
%
%IMPORTING DATA
%   You can also import various types of data into MATLAB.  This includes
%   importing from MAT-files, text files, binary files, and HDF files.  To 
%   import data from MAT-files, use the LOAD function.  To use the
%   graphical user interface to MATLAB's import functions, type UIIMPORT.
%
%   For further information on importing data, see Import and Export Data
%   in the MATLAB Help Browser under the following headings:
%
%       MATLAB -> Programming Fundamentals
%       MATLAB -> External Interfaces -> Programming Interfaces
%
%   See also CLEAR, LOAD.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.11.4.6 $  $Date: 2009/02/13 15:12:11 $
%   Built-in function.
