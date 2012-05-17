function [isvalid, errmsg, errid] = thisvalidate(h)
%THISVALIDATE   

%   Author(s): R. Losada
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/12/26 22:14:45 $

[isvalid, errmsg, errid] = checkincfreqs(h,{'Fpass1','Fstop1','Fstop2','Fpass2'});

% [EOF]
