function [isvalid, errmsg, errid] = thisvalidate(h)
%THISVALIDATE   Check that this object is valid.

%   Author(s): R. Losada
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:15:08 $

[isvalid, errmsg, errid] = checkincfreqs(h,{'Fpass','Fstop'});

% [EOF]
