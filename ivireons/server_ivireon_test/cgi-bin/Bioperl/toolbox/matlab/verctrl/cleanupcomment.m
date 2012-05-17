function str = cleanupcomment(comment)
%CLEANUPCOMMENT Remove whitespace from a comment.
%   STR = CLEANUPCOMMENT(COMMENT) returns str that has
%   linefeeds and carriage returns converted to spaces
%   and multiple spaces compressed to a single space.
%
%   See also CLEARCASE, PVCS, RCS, and SOURCESAFE.
%

% Copyright 1998-2004 The MathWorks, Inc.
% $Revision: 1.4.4.1 $  $Date: 2004/06/16 22:23:32 $

% Replace linefeeds and carriage returns.
str = strrep(comment, char(10), ' ');
str = strrep(str, char(13), ' ');

% Replace all double spaces with single spaces.
while (strfind(str, '  '))
	str = strrep(str, '  ', ' ');
end

% Remove leading and trailing space.
str = deblank(str);
str = fliplr(deblank(fliplr(str)));

% end function cleanupcomment




