function i = strmatch(str,strs,flag)
%STRMATCH Find possible matches for strings for Java objects.
%
%   STRMATCH will be removed in a future release. Use STRNCMP instead.
%
%   See also STRMATCH.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2009/11/16 22:27:41 $

if (nargin < 3)
  i = strmatch(fromOpaque(str),fromOpaque(strs));
else
  i = strmatch(fromOpaque(str),fromOpaque(strs),fromOpaque(flag));
end



