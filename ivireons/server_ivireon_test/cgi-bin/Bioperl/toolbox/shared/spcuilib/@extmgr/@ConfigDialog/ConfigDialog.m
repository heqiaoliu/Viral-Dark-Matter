function this = ConfigDialog(hDriver)
%CONFIGDIALOG Dialog representing extension configuration database.
%   extmgr.ConfigDialog(hDriver) creates a DDG dialog for interacting with the
%   configuration database.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2008/12/04 23:19:58 $

this        = extmgr.ConfigDialog;
this.Driver = hDriver;

hApplication = get(hDriver, 'Application');

% Initialize DialogBase class
this.init('', hApplication);

updateTitleBar(this);

% [EOF]
