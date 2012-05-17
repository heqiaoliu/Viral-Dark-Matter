function setupDisabledOrEnabled(this)
%SETUPDISABLEDORENABLED Prepare dialog depending on license config.
% In the Simulink operating mode the mask can be read-only (when using
% Filter Design Toolbox features that are no longer available) or fully
% editable (when reset).

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:38:20 $

% In the Simulink operating mode the mask can be read-only (when using
% Filter Design Toolbox features that are no longer available) or fully
% editable (when reset).
this.isResetable = true;

if ~isfdtbxinstalled && strcmpi(this.OperatingMode,'simulink'),
    % Turn Enabled false temporarily to avoid premature reset before
    % everything is loaded.
    this.Enabled = false;
else
    this.Enabled = true;
end

% [EOF]
