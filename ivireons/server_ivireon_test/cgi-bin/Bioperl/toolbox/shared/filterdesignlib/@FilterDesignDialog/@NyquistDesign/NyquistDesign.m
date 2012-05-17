function this = NyquistDesign(varargin)
%NYQUISTDESIGN   Construct a NYQUISTDESIGN object.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/10/16 06:38:50 $

this = FilterDesignDialog.NyquistDesign;

set(this, 'VariableName', uiservices.getVariableName('Hnyq'), varargin{:});

this.Enabled = isfdtbxinstalled;

if isfdtbxinstalled
    set(this, 'FDesign', fdesign.nyquist);
else
    % Setup defaults when we cannot read them from the FDESIGN because 
    % filterdesign is not installed
    set(this, 'Structure', 'Direct-form FIR');
end

set(this, 'DesignMethod', 'Kaiser window');

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedSpecs',      getSpecs(this), ...
    'LastAppliedDesignOpts', getDesignOptions(this));

% [EOF]
