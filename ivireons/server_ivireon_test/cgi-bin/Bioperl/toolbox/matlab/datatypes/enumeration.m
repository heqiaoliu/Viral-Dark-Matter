%ENUMERATION Display class enumeration member and names.
%   ENUMERATION CLASSNAME displays the names of the enumeration members  
%   for the MATLAB class with the name CLASSNAME.
%
%   ENUMERATION(OBJECT) displays the names of the enumeration members for
%   the class of OBJECT.
%
%   M = ENUMERATION(...) returns the enumeration members for the class in  
%   the column vector M of objects.
%
%   [M, S] = ENUMERATION(...) returns the names of the enumeration members 
%   in the cell array of strings S. The names in S correspond element-
%   wise to the enumeration members in M.
%
%   If an enumeration is derived from a built-in class it may specify more 
%   than one name for a given enumeration member.  When you call the 
%   ENUMERATION function with no output arguments, MATLAB displays only the
%   first name for each member (as specified in the class definition). To 
%   see all available enumeration members and their names, use the two-
%   output form [M, S] = ENUMERATION(...).
%
%   Examples based on the following enumeration class:
%
%   classdef Boolean < logical
%       enumeration
%           No(0)
%           Yes(1)
%           Off(0)
%           On(1)
%       end
%    end
%
%   %Example 1: Display the names of the enumeration members for  
%   %class 'Boolean':
%   enumeration Boolean;
%    
%   %Example 2: Get the enumeration members for class 'Boolean' 
%   %in a column vector of objects:
%   e = Boolean.Yes;
%   members = enumeration(e);
%
%   %Example 3: Get all available enumeration members and their names:
%   [members, names] = enumeration('Boolean');
%
%   See also CLASSDEF.

%   Copyright 2007-2010 The MathWorks, Inc. 
%   Built-in function.
