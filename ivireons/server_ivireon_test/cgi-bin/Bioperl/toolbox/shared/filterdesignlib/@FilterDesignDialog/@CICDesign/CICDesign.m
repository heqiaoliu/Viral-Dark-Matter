function this = CICDesign(varargin)
%CICDESIGN   Construct a CICDESIGN object.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/10/16 06:38:35 $

this = FilterDesignDialog.CICDesign;

set(this, 'VariableName', uiservices.getVariableName('Hcic'), ...
    'FilterType', 'Decimator', ...
    varargin{:});

this.Enabled = isfdtbxinstalled;

if isfdtbxinstalled
    set(this, 'FDesign', fdesign.decimator(2, 'cic'));
    updateMethod(this);
else
    % Setup defaults when we cannot read them from the FDESIGN because 
    % filterdesign is not installed
    set(this, 'DesignMethod', 'multisection', 'Structure', 'cicdecim');
end

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedSpecs',      getSpecs(this));

% [EOF]
