function resetoperations(hObj)
%RESETOPERATIONS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:13:04 $

% We do not want to listen to any changes to Filters, since filters changes
% cannot be undone/cancelled.
dialog_resetoperations(hObj, 'Filters');

% [EOF]
