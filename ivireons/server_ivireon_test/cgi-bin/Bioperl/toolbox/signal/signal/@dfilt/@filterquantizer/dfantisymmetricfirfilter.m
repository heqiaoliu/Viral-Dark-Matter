function [y,zf,tapIndex] = dfantisymmetricfirfilter(q,b,x,zi,tapIndex)
% DFANTISYMMETRICFIRFILTER Filter for DFILT.DFASYMFIR class in double precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:57:29 $

x = quantizeinput(q,x);
[y,zf,tapIndex] = dfantisymmetricfirfilter(b,x,zi,tapIndex);
