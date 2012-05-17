function [y,zf] = df2tfilter(q,b,a,x,zi)
% DF2TFILTER Filter for DFILT.DF2T class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:30:00 $

x = quantizeinput(q,x);

[y,zf] = sdf2tfilter(b,a,x,zi);

