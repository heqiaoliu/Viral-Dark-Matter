function s = getFullName(h,delimit)
%GETFULLNAME Return full hierarchy name of item.
%  GETFULLNAME(H) returns the full hierarchy name of
%  the item as a cell-array of strings.
%  GETFULLNAME(H,DELIM) returns one concatenated string, using
%  DELIM characters to delimit each hierarchy name.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/02/02 13:12:20 $

if nargin<2, delimit=''; end
s=h.Name;
h=h.up; % get parent, if any
if isempty(delimit)
    s={s};
    while ~isempty(h)
        s=[{h.Name} s]; %#ok
        h=h.up;
    end
else
    while ~isempty(h)
        s=sprintf('%s%s%s',h.Name,delimit,s);
        h=h.up;
    end
end

% [EOF]
