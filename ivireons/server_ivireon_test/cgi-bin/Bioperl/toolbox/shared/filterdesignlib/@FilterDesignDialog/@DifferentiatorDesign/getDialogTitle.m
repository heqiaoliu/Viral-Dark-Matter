function dialogTitle = getDialogTitle(this)
%GETDIALOGTITLE   Get the dialogTitle.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 04:22:05 $

if strcmpi(this.OperatingMode, 'Simulink')
    dialogTitle = FilterDesignDialog.message('DifferentiatorFilter');
else
    dialogTitle = FilterDesignDialog.message('DifferentiatorDesign');
end

% [EOF]
