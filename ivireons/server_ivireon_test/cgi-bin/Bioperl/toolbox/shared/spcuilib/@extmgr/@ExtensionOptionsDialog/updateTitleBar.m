function updateTitleBar(this)
%UPDATETITLEBAR   Update the titlebar when the application changes its name

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:29:02 $

% Build the dialog title from the name of the extension and the application
optionsStr = sprintf('%s Options', getFullName(this.Register));
if ismethod(this.hAppInst, 'getDialogTitle')
    prefix = getDialogTitle(this.hAppInst);
    suffix = [' - ' optionsStr];
else
    prefix = optionsStr;
    suffix = '';
end

% Save the extension handle and the dialog properties.
set(this, ...
    'TitlePrefix', prefix, ...
    'TitleSuffix', suffix);

show(this, false);

% [EOF]
