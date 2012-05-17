function this = ExtensionOptionsDialog(hDriver, type, name)
%EXTENSIONOPTIONSDIALOG Construct an EXTENSIONOPTIONSDIALOG object

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/03/09 19:32:50 $

this = extmgr.ExtensionOptionsDialog;

hRegister = hDriver.RegisterDb.findRegister(type, name);
hConfig   = hDriver.ConfigDb.findConfig(type, name);

% Make sure that we have a complete propertyDb in the configuration.
mergePropDb(hRegister, hConfig);

this.Listen_Client = handle.listener( ...
    hDriver.Application, 'UpdateDialogsTitleBarEvent', ...
    @(hh,ev)updateTitleBar(this));

set(this, ...
    'hAppInst', hDriver.Application, ...
    'Register', hRegister, ...
    'Config',   hConfig);

updateTitleBar(this);

% [EOF]
