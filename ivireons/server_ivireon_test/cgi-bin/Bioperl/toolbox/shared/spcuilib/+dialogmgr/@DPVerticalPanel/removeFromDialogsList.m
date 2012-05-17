function wasOnList = removeFromDialogsList(dp,dlg)
% Remove dialog from Dialogs master list, if present.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:40:10 $

test = dlg.DialogContent.ID == getID(dp.Dialogs);
dp.Dialogs(test) = [];
wasOnList = any(test);
