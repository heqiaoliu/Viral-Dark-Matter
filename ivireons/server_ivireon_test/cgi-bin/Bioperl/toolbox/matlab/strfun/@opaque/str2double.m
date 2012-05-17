function x = str2double(s)
%STR2DOUBLE Convert Java string object to MATLAB double.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2006/06/20 20:12:32 $

x = str2double(fromOpaque(s));
