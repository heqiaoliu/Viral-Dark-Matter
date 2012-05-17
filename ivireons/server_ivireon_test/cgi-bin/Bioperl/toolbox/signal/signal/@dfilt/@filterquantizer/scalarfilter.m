function [y,zf] = scalarfilter(q,b,x,zi)
% SCALARFILTER Filter for DFILT.SCALAR class in double precision mode

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:57:54 $


x = quantizeinput(q,x);
y = b * x;
zf = zi;


