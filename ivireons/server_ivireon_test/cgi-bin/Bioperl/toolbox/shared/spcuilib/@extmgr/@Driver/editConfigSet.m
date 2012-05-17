function varargout = editConfigSet(this,varargin)
%EDITCONFIGSET Open extension configuration properties dialog.
%   EDITCONFIGSET(H) opens a new configuration dialog, or updates the
%   existing dialog, based on current extension driver information.
%
%   EDITCONFIGSET(H, false) will not open a new dialog, but will attempt to
%   update an existing one.

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/10/29 16:08:08 $

hDlg = get(this, 'Dialog');

if isempty(hDlg)
    
    % If we are just updating the dialog and we don't have one yet, just
    % return early.
    if nargin > 1 && ~varargin{1} && nargout < 1
        return
    end
    
    % Create dialog object
    hDlg = extmgr.ConfigDialog(this);
    
    set(hDlg, 'HiddenTypes', this.HiddenTypes, 'HiddenExtensions', this.HiddenExtensions);
    
    hDlg.MessageLog = this.MessageLog;
    this.Dialog = hDlg;
end

show(hDlg, varargin{:});

if nargout > 0
    varargout = {hDlg};
end

% [EOF]
