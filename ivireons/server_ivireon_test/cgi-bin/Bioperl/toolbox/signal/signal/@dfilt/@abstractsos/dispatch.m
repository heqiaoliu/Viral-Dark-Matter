function Hd = dispatch(this)
%DISPATCH   Dispatch to a light weight dfilt.

%   Author(s): J. Schickler
%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/20 15:34:55 $

checksv(this);

Hd = lwdfilt.sos(this.SOSMatrix, this.ScaleValues);

Hd.refSOSMatrix   = this.refsosMatrix;
Hd.refScaleValues = this.refScaleValues;

% [EOF]
