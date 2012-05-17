function [y,zf] = scalarfilter(q,b,x,zi)
% SCALARFILTER Filter for DFILT.SCALAR class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:31:27 $

x = quantizeinput(q,x);
y = b * x;
zf = single(zi);

