function pixval(arg1, arg2)
%PIXVAL produces an error and is no longer supported. Use IMPIXELINFO
%instead for pixel reporting. Use IMDISTLINE instead for measuring
%distance.

%   Copyright 1993-2008 The MathWorks, Inc.    
%   $Revision: 1.23.4.8 $  $Date: 2008/02/07 16:30:24 $

id = sprintf('Images:%s:obsoleteFunction',mfilename);
error(id,'%s is obsolete and has been removed.\n IMPIXELINFO is its recommended replacement for pixel reporting.\n IMDISTLINE is its recommended replacement for measuring distance.',upper(mfilename));