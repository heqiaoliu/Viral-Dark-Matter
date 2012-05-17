function dialogTitle = getDialogTitle(this)
%GETDIALOGTITLE   Get the dialogTitle.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 04:22:23 $

if strcmpi(this.OperatingMode, 'Simulink')
    dialogTitle = 'Halfband Filter';
else
    dialogTitle = FilterDesignDialog.message('HalfbandDesign');
end

% [EOF]
