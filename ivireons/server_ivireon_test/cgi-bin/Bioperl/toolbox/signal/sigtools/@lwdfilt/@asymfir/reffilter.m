function Hd = reffilter(this)
%REFFILTER   Returns the double representation of the filter object.

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:20:10 $

Hd = lwdfilt.asymfir;
Hd.Numerator = this.refnum;
Hd.refnum = this.refnum;



% [EOF]
