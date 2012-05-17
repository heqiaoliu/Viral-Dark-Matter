function [y,zf,tapIndex] = dffirfilter(q,b,x,zi,tapIndex)

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:30:15 $

x = quantizeinput(q,x);
[y,zf,tapIndex] = sdffirfilter(b,x,zi,tapIndex);

