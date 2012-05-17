function htmlOut = matdiff(fname1, fname2)
%MATDIFF Compare similarity of two MAT-files
%   MATDIFF(fname1,fname2) brings up an HTML report showing the differences
%   between the two files.  This feature is only supported if Java is
%   available.
%
%   S = MATDIFF(...) returns the HTML report in the string S.  This syntax
%   is supported even if Java is not available.

% Copyright 2007-2009 The MathWorks, Inc.

error(nargchk(2,2,nargin));

if nargout == 0
    error(javachk('swing'));
    % Invoke the Comparison Tool, which will perform the comparison and
    % display the result.
    comparisons_private('comparefiles',fname1,fname2);
else
    htmlOut = comparisons_private('matdiff',fname1,fname2);
end

