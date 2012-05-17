function this = PulseShapingDesign(varargin)
%PULSESHAPINGDESIGN Construct a PULSESHAPINGDESIGN object

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/10/16 06:38:54 $

this = FilterDesignDialog.PulseShapingDesign;

set(this, 'Order', '48', 'VariableName', uiservices.getVariableName('Hps'), varargin{:});

% Prepare dialog depending on license config and operating mode
setupDisabledOrEnabled(this);

set(this, 'FDesign', fdesign.pulseshaping);
set(this, 'DesignMethod', 'Window');

% Set the default values for interpolation and decimation
this.Factor = '8';

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedSpecs',      getSpecs(this), ...
    'LastAppliedDesignOpts', getDesignOptions(this));

% [EOF]
