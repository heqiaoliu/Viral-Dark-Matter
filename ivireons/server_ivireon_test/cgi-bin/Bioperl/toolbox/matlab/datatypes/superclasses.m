%SUPERCLASSES Display superclass names.
%   SUPERCLASSES CLASSNAME displays the names of all visible superclasses 
%   of the MATLAB class with the name CLASSNAME.  Visible classes are those
%   with class attribute Hidden set to false (the default).
%
%   SUPERCLASSES(OBJECT) displays the names of the visible superclasses for
%   the class of OBJECT, where OBJECT is an instance of a MATLAB class.
%   OBJECT can be either a scalar object or an array of objects.
%
%   S = SUPERCLASSES(...) returns the superclass names in a cell array of 
%   strings.
%
%   %Example:
%   %Retrieve the names of the visible superclasses of class 
%   %AbstractFileDialog and store the result in a cell array of strings.
%   classnames = superclasses('AbstractFileDialog');
%
%   See also PROPERTIES, METHODS, EVENTS, CLASSDEF.

%   Copyright 2007-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:17:42 $
%   Built-in function.