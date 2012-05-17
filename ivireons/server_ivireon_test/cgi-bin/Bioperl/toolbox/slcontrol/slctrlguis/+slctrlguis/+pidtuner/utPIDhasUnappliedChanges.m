function [HasUnappliedChanges hDialog] = utPIDhasUnappliedChanges(blkh)
% PID helper function

% This function returns PID block configurations

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:53:56 $

hBlock = handle(get_param(blkh,'Handle'));
hSource = hBlock.getDialogSource;
hDialog = hSource.getOpenDialogs;
if isempty(hDialog)
    HasUnappliedChanges = false;
else
    HasUnappliedChanges = hDialog{1}.hasUnappliedChanges;
    hDialog = hDialog{1};
end