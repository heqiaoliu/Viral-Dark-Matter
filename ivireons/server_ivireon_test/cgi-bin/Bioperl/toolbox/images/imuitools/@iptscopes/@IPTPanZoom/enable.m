function enable(this)
%ENABLE   Enable the extension.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/04/28 03:23:24 $

hSrc = this.Application.DataSource;

if isempty(hSrc) || ~isDataLoaded(hSrc)
    enab = 'off';
else
    enab = 'on';
end

enableGUI(this, enab);

% [EOF]
