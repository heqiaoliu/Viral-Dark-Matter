function wasOnList = removeFromUndockedList(dp,dlg)
% Remove dialog from undocked dialog list, if present.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:40:11 $

test = dlg.DialogContent.ID == getID(dp.UndockedDialogs);
dp.UndockedDialogs(test) = [];
wasOnList = any(test);

