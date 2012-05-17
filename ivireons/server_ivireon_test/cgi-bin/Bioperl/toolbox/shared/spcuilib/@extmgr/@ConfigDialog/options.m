function options(this, varargin)
%OPTIONS  Launch the options dialog.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/29 16:08:07 $

switch numel(varargin)
    case 0
        type  = this.Driver.RegisterDb.SortedTypeNames{this.SelectedType+1};
        row   = this.SelectedExtension(this.SelectedType+1);
        hRegs = findVisibleRegisters(this, type);
        type  = hRegs(row+1).Type;
        name  = hRegs(row+1).Name;
    case 1
        hRegister = varargin{1}.Register;
        type = hRegister.Type;
        name = hRegister.Name;
    case 2
        type = varargin{1};
        name = varargin{2};
end

hDlg = find(this, '-function', @(hChild) isRegisterDlg(hChild, type, name));

if isempty(hDlg)
    hDlg = extmgr.ExtensionOptionsDialog(this.Driver, type, name);
    connect(hDlg, this, 'up');
end

hDlg.show;

% -------------------------------------------------------------------------
function b = isRegisterDlg(hChild, type, name)

if isprop(hChild, 'Register') && ...
        strcmp(hChild.Register.Type, type) && ...
        strcmp(hChild.Register.Name, name)
    b = true;
else
    b = false;
end

% [EOF]
