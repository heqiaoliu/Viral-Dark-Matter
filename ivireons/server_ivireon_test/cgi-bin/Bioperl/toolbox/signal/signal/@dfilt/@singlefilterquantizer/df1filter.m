function [y,zfNum,zfDen,nBPtrf,dBPtrf] = df1filter(q,b,a,...
            x,ziNum,ziDen,nBPtr,dBPtr)
% DF1FILTER Filter for DFILT.DF1 class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:29:30 $

x = quantizeinput(q,x);

% Call the single-precision DF1 filter implementation DLL
[y,zfNum,zfDen,nBPtrf,dBPtrf] = sdf1filter(b,a,x,ziNum,ziDen,nBPtr,dBPtr);
