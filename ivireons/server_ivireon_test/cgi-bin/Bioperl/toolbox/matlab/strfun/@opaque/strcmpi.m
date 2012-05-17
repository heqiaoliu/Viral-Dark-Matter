function s = strcmpi(s1,s2)
%STRCMPI Compare strings ignoring case for Java objects.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2006/06/20 20:12:35 $

s = strcmpi(fromOpaque(s1),fromOpaque(s2));



