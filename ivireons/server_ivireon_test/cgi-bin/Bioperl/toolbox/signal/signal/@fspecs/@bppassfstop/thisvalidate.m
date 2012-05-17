function [isvalid, errmsg, errid] = thisvalidate(h)
%THISVALIDATE   

%   Author(s): R. Losada
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:14:27 $

[isvalid, errmsg, errid] = checkincfreqs(h,{'Fstop1','Fpass1','Fpass2','Fstop2'});

% [EOF]
