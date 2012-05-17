function minfo = measureinfo(this)
%MEASUREINFO   Return a structure of information for the measurements.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:01:59 $

minfo.GBW    = 10*log10(.5);
minfo.FilterOrder = this.FilterOrder;
minfo.CombType = this.CombType;

% [EOF]
