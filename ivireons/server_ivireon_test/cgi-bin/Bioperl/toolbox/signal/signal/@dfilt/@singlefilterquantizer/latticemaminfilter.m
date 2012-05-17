function [y,zf] = latticemaminfilter(q,k,kconj,x,zi)
% LATTICEMAMINFILTER Filter for DFILT.LATTICEMAMIN class in single precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:31:13 $

x = quantizeinput(q,x);
[y,zf] = slatticemaminphasefilter(k,kconj,x,zi);
