function [y,zf,tapIndex] = dfantisymmetricfirfilter(q,b,x,zi,tapIndex)
% DFANTISYMMETRICFIRFILTER Filter for DFILT.DFASYMFIR class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:30:09 $

x = quantizeinput(q,x);
[y,zf,tapIndex] = sdfantisymmetricfirfilter(b,x,zi,tapIndex);

