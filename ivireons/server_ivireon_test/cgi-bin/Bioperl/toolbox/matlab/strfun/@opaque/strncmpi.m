function s = strncmpi(s1,s2,n)
%STRNCMPI Compare first N characters of strings ignoring case for Java objects.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2006/06/20 20:12:38 $

s = strncmpi(fromOpaque(s1),fromOpaque(s2),fromOpaque(n));



