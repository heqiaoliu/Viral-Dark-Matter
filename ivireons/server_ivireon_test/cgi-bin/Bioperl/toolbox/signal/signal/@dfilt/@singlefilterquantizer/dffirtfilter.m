function [y,zf] = dffirtfilter(q,b,x,zi)

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:30:20 $


x = quantizeinput(q,x);
[y,zf] = sdffirtfilter(b,x,zi);

