function updateFixedPoint(this, fixedpointmode)
%UPDATEFIXEDPOINT   Update the fixed point.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:24:49 $

if strcmpi(this.OperatingMode, 'Simulink')
    return;
end

if isempty(this.FixedPoint)
    this.FixedPoint = FilterDesignDialog.FixedPoint;
end

set(this.FixedPoint, 'Structure', convertStructure(this, this.Structure));

% [EOF]
