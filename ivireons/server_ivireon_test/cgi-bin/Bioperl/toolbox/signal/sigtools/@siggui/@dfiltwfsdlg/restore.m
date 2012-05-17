function restore(hObj)
%RESTORE Restore the original default fs

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/04/22 20:03:58 $

setpref('SignalProcessingToolbox', 'DefaultFs', 1);
oldBU = get(hObj, 'BackupFs');
newBU.Units = 'Hz';
newBU.Value = '1';
set(hObj, 'BackupFs', repmat(newBU, length(oldBU), 1));
set(hObj, 'isApplied', 0);

% [EOF]
