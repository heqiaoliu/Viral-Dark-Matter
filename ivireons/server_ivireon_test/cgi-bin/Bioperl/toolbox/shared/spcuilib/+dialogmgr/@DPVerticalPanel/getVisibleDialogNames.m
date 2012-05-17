function visNames = getVisibleDialogNames(dp)
% Return cell-string of visible dialog names in placement order.
% Used during serialization to translate from "internal" dialog indices
% to "external" dialog names.  Dialog names can be preserved and
% reloaded into the program.  Indices are subject to change from one
% version to another, or even from one instance to another.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:55 $

visNames = {dp.VisibleDialogs.Name};
