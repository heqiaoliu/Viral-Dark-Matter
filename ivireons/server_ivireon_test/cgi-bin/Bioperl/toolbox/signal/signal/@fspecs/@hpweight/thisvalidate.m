function [isvalid, errmsg, errid] = thisvalidate(h)
%THISVALIDATE   

%   Author(s): R. Losada
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/12/26 22:15:01 $

[isvalid, errmsg, errid] = checkincfreqs(h,{'Fstop','Fpass'});

% [EOF]
