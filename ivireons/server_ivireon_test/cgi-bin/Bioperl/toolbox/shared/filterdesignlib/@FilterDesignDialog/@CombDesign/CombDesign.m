function this = CombDesign(varargin)
%COMBDESIGN   Construct a COMBDESIGN object.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/16 06:38:37 $

this = FilterDesignDialog.CombDesign;

% The Comb design only works for IIR filters and does not support minimum
% order.
set(this, 'ImpulseResponse', 'IIR', ...
    'OrderMode', 'specify', ...
    'Order', '10', ...
    'VariableName', uiservices.getVariableName('Hcomb'), varargin{:});

this.Enabled = isfdtbxinstalled;

if isfdtbxinstalled
    set(this, 'FDesign', fdesign.comb);
    updateMethod(this);
else
    % Setup defaults when we cannot read them from the FDESIGN because 
    % filterdesign is not installed
    set(this, 'DesignMethod', 'Butterworth', 'Structure', 'Direct-form II');
end

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedSpecs',      getSpecs(this), ...
    'LastAppliedDesignOpts', getDesignOptions(this));

% [EOF]
