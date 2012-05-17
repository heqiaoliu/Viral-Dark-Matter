function this = ParamEqDesign(varargin)
%PARAMEQDESIGN Construct a PARAMEQDESIGN object

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/16 06:38:52 $

this = FilterDesignDialog.ParamEqDesign;

set(this, 'VariableName', uiservices.getVariableName('Hpe'), ...
    'Order', '10', ...
    'ImpulseResponse', 'IIR', varargin{:});

this.Enabled = isfdtbxinstalled;

if isfdtbxinstalled
    set(this, 'FDesign', fdesign.parameq);
    updateMethod(this);
else
    % Setup defaults when we cannot read them from the FDESIGN because 
    % filterdesign is not installed
    set(this, 'DesignMethod', 'Butterworth', 'Structure', 'Direct-form II, Second-order sections');
end

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedSpecs',      getSpecs(this), ...
    'LastAppliedDesignOpts', getDesignOptions(this));

% [EOF]
