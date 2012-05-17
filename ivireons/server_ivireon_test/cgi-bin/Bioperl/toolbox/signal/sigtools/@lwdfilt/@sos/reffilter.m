function Hd = reffilter(this)
%REFFILTER   Returns the double representation of the filter object.

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:20:15 $

Hd = lwdfilt.sos;
Hd.sosMatrix = this.refsosMatrix;
Hd.refsosMatrix = this.refsosMatrix;
Hd.ScaleValues = this.refScaleValues;
Hd.refScaleValues = this.refScaleValues;

% [EOF]
