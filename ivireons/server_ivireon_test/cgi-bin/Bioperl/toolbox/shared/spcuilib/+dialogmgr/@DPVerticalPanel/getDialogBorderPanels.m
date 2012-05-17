function hPanels = getDialogBorderPanels(dp,dlgs)
% Return a vector of DialogBorder Panel handles, each an HG uipanel object.
% One handle is returned for each docked Dialog object in DialogPanel.
% There may be zero or more docked DialogBorder panels in DialogPanel.
%
% getDialogBorderPanels(dp,dlg) returns DialogBorder Panel handles for
% dialog handles specified in vector dlg.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:48 $

if nargin<2
    dlgs = dp.DockedDialogs;
end
if isempty(dlgs)
    hPanels = [];
else
    db = [dlgs.DialogBorder];
    hPanels = [db.Panel];
end

