function this = FracDelayDesign(varargin)
%FRACDELAYDESIGN   Construct a FRACDELAYDESIGN object.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/10/16 06:38:41 $

this = FilterDesignDialog.FracDelayDesign;

set(this, 'VariableName', uiservices.getVariableName('Hfd'), ...
    'Order', '3', ...
    'OrderMode', 'specify', varargin{:});

this.Enabled = isfdtbxinstalled;

if isfdtbxinstalled
    set(this, 'FDesign', fdesign.fracdelay);
    updateMethod(this);
else
    % Setup defaults when we cannot read them from the FDESIGN because 
    % filterdesign is not installed
    set(this, 'DesignMethod', 'Lagrange interpolation', 'Structure', 'Farrow Fractional delay');
end

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState', getState(this), ...
    'LastAppliedSpecs', getSpecs(this));

% [EOF]
