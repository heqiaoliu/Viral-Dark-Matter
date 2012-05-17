function [retVal,idx] = uniquePath(string_cell, varargin)
%UNIQUEPATH-This returns the unique pathes in the cell array passed in.  This
%differes from the MATLAB function unique, in that the original order is
%maintained, and not alphabetized.  On PC paltforn, the case of path will 
%be ignored.
%

%    Copyright 1994-2005 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $ $Date: 2005/12/19 07:37:00 $

if ispc
    [retVal,idx] = RTW.unique(string_cell, 'ignorecase',varargin{1:end});
else
    [retVal,idx] = RTW.unique(string_cell, varargin{1:end});
end
