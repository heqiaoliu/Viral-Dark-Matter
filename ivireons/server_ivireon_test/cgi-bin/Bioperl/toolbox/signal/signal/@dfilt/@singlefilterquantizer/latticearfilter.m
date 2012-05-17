function [y,zf] = latticearfilter(q,k,kconj,x,zi)
% LATTICEARFILTER Filter for DFILT.LATTICEAR class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:30:57 $

x = quantizeinput(q,x);
[y,zf] = slatticearfilter(k,kconj,x,zi);
