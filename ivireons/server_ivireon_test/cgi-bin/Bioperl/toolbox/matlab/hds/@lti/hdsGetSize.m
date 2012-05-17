function s = hdsGetSize(ltiarray)
%HDSGETSIZE  Return size of data point array.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:15:05 $
s = size(ltiarray);
s = [s(3:end) ones(1,4-length(s))];