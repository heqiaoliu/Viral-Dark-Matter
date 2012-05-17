function y = isDuplicateName(hGroup,hChild)
% Check for duplicate name
%   - assume small total number of children
%   - so we use a simple, linear (O(n)) search
% Provides a case-insensitive match on .Name property.
%
% If name of hChild matches the name of any child in hGroup,
%   return true.
% If name of hChild does NOT match any child in hGroup,
%   or if there are no children, return false.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:31:02 $

h = hGroup.find('-depth',1,'Name',hChild.Name);

% to be a duplicate entry,
%  - result can't be empty (no match = not a duplicate)
%  - result can't be a scalar entry matching hGroup
%    (i.e., the only match is the parent, which itself
%     is clearly is not matching any child)
%  (note that there's no way to exclude the parent from the search)
%
y = ~isempty(h) && ~isequal(h,hGroup);

% [EOF]
