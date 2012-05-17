function minfo = measureinfo(this)
%MEASUREINFO   Return a structure of information for the measurements.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:40 $

minfo.GBW    = this.GBW;
minfo.FilterOrder = this.NumPeaksOrNotches;
minfo.CombType = this.CombType;

% [EOF]
