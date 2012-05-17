function [y,zf] = secfilter(this,x,zi)
%SECFILTER Filter this section.
%   [Y,Zf] = SECFILTER(this,X,ZI) filters this section.  This function is only
%   intended to be called from DFILT/FILTER.  

%   Author(s): V. Pellissier, M.Chugh
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/10/14 16:24:50 $

q = this.filterquantizer;
b = this.Latency;
[y,zf] = delayfilter(q,b,x,zi);

% [EOF]
