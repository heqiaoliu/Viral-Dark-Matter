function Hd = reffilter(this)
%REFFILTER   Returns the double representation of the filter object.

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:20:28 $

Hd = lwdfilt.tf;
Hd.Numerator = this.refnum;
Hd.refnum = this.refnum;
Hd.Denominator = this.refden;
Hd.refden = this.refden;



% [EOF]
