function this = LowpassDesign(varargin)
%LOWPASSDESIGN   Construct a LOWPASSDESIGN object.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/10/16 06:38:48 $

this = FilterDesignDialog.LowpassDesign;

set(this, 'VariableName', uiservices.getVariableName('Hlp'), varargin{:});

% Prepare dialog depending on license config and operating mode
setupDisabledOrEnabled(this);

set(this, 'FDesign', fdesign.lowpass);
set(this, 'DesignMethod', 'Equiripple');

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedSpecs',      getSpecs(this), ...
    'LastAppliedDesignOpts', getDesignOptions(this));

% [EOF]
