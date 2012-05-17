function resetoperations(hDlg, varargin)
%RESETOPERATIONS Create a transaction incase of a cancel.
%   RESETOPERATIONS(hDLG) Create a transaction incase of a cancel.  This
%   transaction will track all changes to the object and undo them if the
%   cancel button is selected.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2008/05/31 23:28:03 $

% This can be private

% setappdata(hDlg.FigureHandle, 'PreviousState', getstate(hDlg));

% Delete the old transactions
delete(hDlg.Operations);

% Create the transaction, ignore the isApplied property
hT(1) = sigdatatypes.transaction(hDlg, ...
    'isApplied', 'Enable', 'Visible', 'DialogHandles', varargin{:});

hChildren = allchild(hDlg);

for indx = 1:length(hChildren),
    hT(1+indx) = sigdatatypes.transaction(hChildren(indx));
end

set(hDlg,'Operations',hT);

% [EOF]
