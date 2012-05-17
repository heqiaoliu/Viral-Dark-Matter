function cancel(this)
%CANCEL The cancel action of the Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.5 $  $Date: 2008/05/31 23:28:02 $

% Hide the dialog, but not through the object.  This avoids the transaction
% finding the change, but we do not see the "cancel" operation
if isrendered(this), set(this,'Visible','Off'); end

% If the Dialog controls have not been applied, reset them
if ~get(this,'isApplied'),
    
%     setstate(this, getappdata(this.FigureHandle, 'PreviousState'));
    
    % Undo all the transactions
    cancel(this.Operations);
end

% Create a new transaction for the next time the dialog is opened
resetoperations(this);

send(this, 'DialogCancelled', handle.EventData(this, 'DialogCancelled'));

% [EOF]
