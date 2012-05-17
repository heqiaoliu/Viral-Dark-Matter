function s = strcmp(s1,s2)
%STRCMP Compare strings for Java objects.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2006/06/20 20:12:34 $

s = strcmp(fromOpaque(s1),fromOpaque(s2));


