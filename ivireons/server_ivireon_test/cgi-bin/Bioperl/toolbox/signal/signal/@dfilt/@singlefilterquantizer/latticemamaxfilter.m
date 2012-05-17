function [y,zf] = latticemamaxfilter(q,k,kconj,x,zi)
% LATTICEMAMAXFILTER Filter for DFILT.LATTICEMAMAX class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:31:08 $

x = quantizeinput(q,x);
[y,zf] = slatticemamaxphasefilter(k,kconj,x,zi);

