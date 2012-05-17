function [isvalid, errmsg, errid] = thisvalidate(this)
%THISVALIDATE   Returns true if this object is valid.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:35:45 $

isvalid = 1;
errmsg = [];
errid = [];
if (this.NormalizedFrequency && this.Fpass~=1) || (~this.NormalizedFrequency && this.Fpass~=this.Fs/2)
    [isvalid, errmsg, errid] = checkincfreqs(this,{'Fpass','Fstop'});
end

% [EOF]
