function updateTitleBar(this, ed) %#ok
%UPDATETITLEBAR Respond to updateTitleBar event.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/09/09 21:28:58 $

% Get the title of this dialog from the application.  If they do not
% implement getAppName, then the dialog will simply be 'Configuration'.
if ismethod(this.hAppInst, 'getDialogTitle')
    appName = getDialogTitle(this.hAppInst);
    this.TitleSuffix = ' - Configuration';
else
    appName = 'Configuration';
end

this.TitlePrefix = appName;

show(this, false);

% [EOF]
