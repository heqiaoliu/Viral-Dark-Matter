function h = copy(this)
%COPY   Copy the designer.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:01:18 $

h = fdesign.pulseshaping;

h.PulseShape = this.PulseShape;
h.PulseShapeObj = copy(this.PulseShapeObj);

% [EOF]
