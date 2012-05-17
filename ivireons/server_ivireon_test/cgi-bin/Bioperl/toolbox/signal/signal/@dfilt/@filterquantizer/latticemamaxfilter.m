function [y,zf] = latticemamaxfilter(q,k,kconj,x,zi)
% LATTICEMAMAXFILTER Filter for DFILT.LATTICEMAMAX class in double precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:57:44 $

x = quantizeinput(q,x);
[y,zf] = latticemamaxphasefilter(k,kconj,x,zi);

