function t = isspace(c)
%ISSPACE True for white space characters in Java objects.
 
%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2006/06/20 20:12:18 $

t = isspace(fromOpaque(c));

