function [y,zf,tapidxf] = df2filter(q,b,a,x,zi,tapidxi)
% DF2FILTER Filter for DFILT.DF2 class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:29:50 $

x = quantizeinput(q,x);

% Call the DF2 filter implementation DLL
[y,zf,tapidxf] = sdf2filter(b,a,x,zi,tapidxi);
