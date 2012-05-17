function s = findstr(s1,s2)
%FINDSTR Find one string within another for Java objects.
%
%   FINDSTR will be removed in a future release. Use STRFIND instead.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2009/11/16 22:27:40 $

s = findstr(fromOpaque(s1),fromOpaque(s2));




