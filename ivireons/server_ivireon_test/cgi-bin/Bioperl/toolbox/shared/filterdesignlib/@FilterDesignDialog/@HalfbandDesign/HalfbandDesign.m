function this = HalfbandDesign(varargin)
%HALFBANDDESIGN   Construct a HALFBANDDESIGN object.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/10/16 06:38:42 $

this = FilterDesignDialog.HalfbandDesign;

set(this, 'VariableName', uiservices.getVariableName('Hhb'), varargin{:});

this.Enabled = isfdtbxinstalled;

if isfdtbxinstalled
    set(this, 'FDesign', fdesign.halfband);
    updateMethod(this);
else
    % Setup defaults when we cannot read them from the FDESIGN because 
    % filterdesign is not installed
    set(this, 'DesignMethod', 'Equiripple', 'Structure', 'Direct-form FIR');
end

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedSpecs',      getSpecs(this), ...
    'LastAppliedDesignOpts', getDesignOptions(this));

% [EOF]
