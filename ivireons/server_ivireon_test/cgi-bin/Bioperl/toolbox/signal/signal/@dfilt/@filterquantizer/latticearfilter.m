function [y,zf] = latticearfilter(q,k,kconj,x,zi)
% LATTICEARFILTER Filter for DFILT.LATTICEAR class in double precision mode

%   Author(s): V.Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:57:40 $

x = quantizeinput(q,x);
[y,zf] = latticearfilter(k,kconj,x,zi);




