function this = ISincLPDesign(varargin)
%ISINCLPDESIGN   Construct a ISINCLPDESIGN object.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/10/16 06:38:47 $

this = FilterDesignDialog.ISincLPDesign;

set(this, 'VariableName', uiservices.getVariableName('Hisinc'), varargin{:});

this.Enabled = isfdtbxinstalled;

if isfdtbxinstalled
    set(this, 'FDesign', fdesign.isinclp);
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
