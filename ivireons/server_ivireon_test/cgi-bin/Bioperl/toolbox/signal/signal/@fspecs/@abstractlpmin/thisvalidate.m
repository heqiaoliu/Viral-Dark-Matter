function [isvalid, errmsg, errid] = thisvalidate(h)
%THISVALIDATE   Checks if this object is valid.

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:26:37 $

[isvalid, errmsg, errid] = checkincfreqs(h,{'Fpass','Fstop'});

% [EOF]
