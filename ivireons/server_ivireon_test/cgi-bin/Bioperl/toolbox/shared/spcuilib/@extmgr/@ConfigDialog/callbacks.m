function callbacks(this, fcn, hDlg)
%CALLBACKS Callbacks for the action buttons on the dialog.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2010/01/25 22:46:35 $

%#ok<*DEFNU> Suppress the "unused function" warning.  All these functions
% are used via the FEVAL call.

feval(fcn, this, hDlg);

% -------------------------------------------------------------------------
function editOptions(this, ~)

options(this);

% -------------------------------------------------------------------------
function ok(this, hDlg)

apply(this, hDlg);
if isempty(this.LastErrorCondition)
    this.close;
end

% -------------------------------------------------------------------------
function cancel(this, ~)

this.close;

% -------------------------------------------------------------------------
function apply(this, hDlg)

hDlg.apply;
if isempty(this.LastErrorCondition)
    hDlg.setEnabled('Apply', false);
end

% Make sure that the Options button's enable state reflects the new state
% of the currently selected extension.
hDlg.setEnabled('Options', isOptionsEnabled(this));

% [EOF]
