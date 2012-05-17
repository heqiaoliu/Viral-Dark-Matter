function [y,zf,tapIndex] = dffirfilter(q,b,x,zi,tapIndex)

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:57:30 $

x = quantizeinput(q,x);
[y,zf,tapIndex] = dffirfilter(b,x,zi,tapIndex);
