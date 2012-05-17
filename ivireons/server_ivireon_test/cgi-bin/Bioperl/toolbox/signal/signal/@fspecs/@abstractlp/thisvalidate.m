function [isvalid, errmsg, errid] = thisvalidate(h)
%THISVALIDATE   Validate this object.

%   Author(s): R. Losada
%   Copyright 2003-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:26:31 $

[isvalid, errmsg, errid] = checkincfreqs(h, {'Fpass','Fstop'});

% [EOF]
