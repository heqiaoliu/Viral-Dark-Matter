function this = HighpassDesign(varargin)
%HIGHPASSDESIGN   Construct a HIGHPASSDESIGN object.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/10/16 06:38:43 $

this = FilterDesignDialog.HighpassDesign;

set(this, 'VariableName', uiservices.getVariableName('Hhp'), ...
    varargin{:});

% Prepare dialog depending on license config and operating mode
setupDisabledOrEnabled(this);

set(this, 'FDesign', fdesign.highpass);
set(this, 'DesignMethod', 'Equiripple');

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedSpecs',      getSpecs(this), ...
    'LastAppliedDesignOpts', getDesignOptions(this));

% [EOF]
