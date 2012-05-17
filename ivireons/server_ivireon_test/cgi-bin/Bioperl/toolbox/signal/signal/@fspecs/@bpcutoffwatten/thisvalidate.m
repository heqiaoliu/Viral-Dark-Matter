function [isvalid, errmsg, errid] = thisvalidate(h)
%THISVALIDATE   Check that this object is valid.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:36:31 $

[isvalid, errmsg, errid] = checkincfreqs(h,{'Fcutoff1','Fcutoff2'});

% [EOF]
