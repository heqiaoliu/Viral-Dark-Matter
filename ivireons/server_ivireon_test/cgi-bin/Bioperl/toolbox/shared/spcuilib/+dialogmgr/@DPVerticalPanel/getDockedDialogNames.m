function names = getDockedDialogNames(dp)
% Return cell-string of docked dialog names in placement order.
% Used during serialization to translate from "internal" dialog indices
% to "external" dialog names.  Dialog names can be preserved and
% reloaded into the program.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:51 $

names = {dp.DockedDialogs.Name};
