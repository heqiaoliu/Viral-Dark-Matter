function [y,zf] = latticearmafilter(q,k,kconj,ladder,x,zi)
% LATTICEARMAFILTER Filter for DFILT.LATTICEARMA class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:31:02 $

x = quantizeinput(q,x);
[y,zf] = slatticearmafilter(k,kconj,ladder,x,zi);
