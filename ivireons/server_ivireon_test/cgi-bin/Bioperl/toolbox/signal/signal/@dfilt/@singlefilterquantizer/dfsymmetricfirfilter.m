function [y,zf,tapIndex] = dfsymmetricfirfilter(q,b,x,zi,tapIndex)
% DFSYMMETRICFIRFILTER Filter for DFILT.DFSYMFIR class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:30:28 $

x = quantizeinput(q,x);
[y,zf,tapIndex] = sdfsymmetricfirfilter(b,x,zi,tapIndex);
