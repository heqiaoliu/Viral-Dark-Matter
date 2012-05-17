function help(this)
%HELP     Help for the configuration dialog.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/04/09 19:03:59 $

if ismethod(this.Driver.Application, 'extensionHelp')
    extensionHelp(this.Driver.Application);
else
    helpview(fullfile(docroot,'toolbox','shared','spcuilib.map'), ...
        'extmgr_configuration_dialog');
end

% [EOF]
