function [y,zf,tapIndex] = dfsymmetricfirfilter(q,b,x,zi,tapIndex)
% DFSYMMETRICFIRFILTER Filter for DFILT.DFSYMFIR class in double precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:57:32 $

x = quantizeinput(q,x);
[y,zf,tapIndex] = dfsymmetricfirfilter(b,x,zi,tapIndex);
