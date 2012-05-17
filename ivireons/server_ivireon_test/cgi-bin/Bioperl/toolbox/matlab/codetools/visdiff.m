function htmlOut = visdiff(fname1, fname2, showchars)
%VISDIFF Compare two files (text, MAT, or binary) or folders
%   VISDIFF(fname1,fname2) opens a report showing the differences between
%   the two specified files or folders.  This feature is only supported
%   if Java is available.

% For internal use and backwards compatibility only:
%
%   VISDIFF(fname1,fname2,showchars) makes the display width for each
%   file "showchars" characters wide.  It only applies to plain-text files;
%   not folders or binary files.
%
%   S = VISDIFF(...) returns a string containing an HTML report of the
%   a differences between the files.  The files will be treated as plain
%   text.  This syntax is not supported for folders, and will produce
%   unreadable results for binary files.  It is supported when Java
%   is not available, as long as the supplied files are not binary.

% Copyright 1984-2010 The MathWorks, Inc.
% $Revision: 1.1.6.13 $

error(nargchk(2,3,nargin));

if nargout == 0
    error(javachk('swing'));
    % Invoke the Comparison Tool, which will perform the comparison and
    % display the result.
    comparisons_private('comparefiles',fname1,fname2);
else
    if nargin < 3
        showchars = 60;
    elseif ischar(showchars)
        showchars = str2double(showchars);
    end
    htmlOut = comparisons_private('textdiff',fname1,fname2,showchars);
end

