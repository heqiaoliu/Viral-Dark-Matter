function [y,zfNum,zfDen] = df1tfilter(q,b,a,x,ziNum,ziDen)
% DF1TFILTER Filter for DFILT.DF1T class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:29:40 $

x = quantizeinput(q,x);

[y,zfNum,zfDen] = sdf1tfilter(b,a,x,ziNum,ziDen);
