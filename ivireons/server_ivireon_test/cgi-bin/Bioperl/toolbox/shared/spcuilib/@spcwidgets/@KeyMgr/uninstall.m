function uninstall(hKeyHandler)
%UNINSTALL Uninstall key handler from figure.
%   UNINSTALL(H) uninstalls key handler from figure.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:48:16 $

% Shut down key handler
set(hKeyHandler.Parent, 'KeyPressFcn','');

% close dialog
close(hKeyHandler);

% [EOF]
