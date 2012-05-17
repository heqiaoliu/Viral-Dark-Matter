function [y,zfNum,zfDen] = df1tfilter(q,b,a,x,ziNum,ziDen)
% DF1TFILTER Filter for DFILT.DF1T class in double precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:57:23 $

x = quantizeinput(q,x);

[y,zfNum,zfDen] = df1tfilter(b,a,x,ziNum,ziDen);
