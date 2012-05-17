function delete(huiRFL)
%DELETE Disconnect RecentFilesList object from menu system.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/08/14 04:07:36 $

disconnectMenu(huiRFL.recentFiles);

% Clear the hWidget handle, so next render() cycle will cause
% recentFiles object to re-connect to the parent menu:
huiRFL.hWidget = [];

% [EOF]
