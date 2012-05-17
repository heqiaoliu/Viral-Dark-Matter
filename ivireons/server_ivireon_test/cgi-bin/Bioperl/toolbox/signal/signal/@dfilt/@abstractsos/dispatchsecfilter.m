function [q, num, den, sv, issvnoteq2one] = dispatchsecfilter(Hd)
%DISPATCHSECFILTER Dispatch info for secfilter

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/01/20 15:34:56 $

q = Hd.filterquantizer;
num = Hd.privNum;
den = Hd.privDen;
sv = Hd.privScaleValues;
issvnoteq2one = checksv(Hd);


% [EOF]
