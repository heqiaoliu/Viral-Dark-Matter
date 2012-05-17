function found = LocalFindStr(h, s1,s2) %#ok<INUSL>
% Abstract:
%	Make findstr more robust by requiring that s1 >= s2 in length.
%       This is because findstr find the smaller of the two. If s1 is
%       a space ' ', findstr will return true, but this routine won't.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/20 08:08:54 $

found = (length(s1) >= length(s2) & ~isempty(findstr(s1,s2)));
%endfunction LocalFindStr
