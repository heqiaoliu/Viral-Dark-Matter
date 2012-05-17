function [y,zf] = dffirtfilter(q,b,x,zi)

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:57:31 $

x = quantizeinput(q,x);
[y,zf] = dffirtfilter(b,x,zi);
