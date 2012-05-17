function [dockedDlgs,hiddenDlgs] = getDockedAndHiddenDialogs(dp)
% Return list of docked dialogs, and list of hidden dialogs as two separate
% lists.  Does NOT return undocked dialogs.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:50 $

% We must compute the hiddenDlgs list
% We have:
% -Master dialog list (all dialogs, visible or not)
% -Docked dialog list (visible)
% -Undocked dialog list (visible)
%
% dockedDlgs: content of DockedDialogs list
% hiddenDlgs: Dialogs list members that are not also in
%             DockedDialogs or UndockedDialogs lists

dockedDlgs = dp.DockedDialogs;
if nargout>1
    allDlgs = dp.Dialogs;
    [~,hiddenIdx] = setdiff(getID(allDlgs), ...
        [getID(dockedDlgs) getID(dp.UndockedDialogs)]);
    hiddenDlgs = allDlgs(hiddenIdx);
end

