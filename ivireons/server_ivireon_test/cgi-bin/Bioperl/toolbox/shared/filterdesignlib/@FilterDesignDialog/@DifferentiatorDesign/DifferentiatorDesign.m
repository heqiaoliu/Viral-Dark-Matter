function this = DifferentiatorDesign(varargin)
%DIFFERENTIATORDESIGN   Construct a DIFFERENTIATORDESIGN object.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/10/16 06:38:39 $

this = FilterDesignDialog.DifferentiatorDesign;

set(this, 'VariableName', uiservices.getVariableName('Hdf'), ...
    'Order', '31', varargin{:});

if ~isfdtbxinstalled
    % Minimum order default is changed when Filter Design Toolbox is not
    % installed.
    set(this, 'OrderMode', 'Specify');
end

% Prepare dialog depending on license config and operating mode
setupDisabledOrEnabled(this);
  
set(this, 'FDesign', fdesign.differentiator);
set(this, 'DesignMethod', 'Equiripple');

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedSpecs',      getSpecs(this), ...
    'LastAppliedDesignOpts', getDesignOptions(this));

% [EOF]
