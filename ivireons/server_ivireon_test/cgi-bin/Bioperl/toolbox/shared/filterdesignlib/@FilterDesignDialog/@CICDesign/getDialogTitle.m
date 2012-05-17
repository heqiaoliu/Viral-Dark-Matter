function dialogTitle = getDialogTitle(this)
%GETDIALOGTITLE   Get the dialogTitle.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 04:21:54 $

if strcmpi(this.OperatingMode, 'Simulink')
    dialogTitle = FilterDesignDialog.message('CICFilter');
else
    dialogTitle = FilterDesignDialog.message('CICDesign');
end

% [EOF]
