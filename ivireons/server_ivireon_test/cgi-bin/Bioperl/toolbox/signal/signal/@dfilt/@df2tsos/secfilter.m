function [y,zf] = secfilter(Hd,x,zi)
%SECFILTER Filter this section.
%   [Y,Zf] = SECFILTER(Hd,X,Zi) filters this section.  This function is only
%   intended to be called from ABSTRACTSOS/FILTER.
%
%   See also DFILT.   
  
%   Author: V. Pellissier
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/01/20 15:35:05 $

[q, num, den, sv, issvnoteq2one] = dispatchsecfilter(Hd);

[y,zf] = df2tsosfilter(q,num,den,sv,issvnoteq2one,x,zi);
