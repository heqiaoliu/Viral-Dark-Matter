function [isvalid, errmsg, errid] = thisvalidate(h)
%THISVALIDATE   Check that this object is valid.

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:14:20 $

[isvalid, errmsg, errid] = checkincfreqs(h,{'Fcutoff1','Fcutoff2'});

% [EOF]
