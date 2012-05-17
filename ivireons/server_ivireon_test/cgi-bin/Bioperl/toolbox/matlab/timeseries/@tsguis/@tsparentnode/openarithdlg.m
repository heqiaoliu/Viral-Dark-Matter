function openarithdlg(h,manager,varargin)

% Copyright 2004 The MathWorks, Inc.

%% If necessary create the dialog. Optional input arg is the name of
%% the selected time series
if nargin==2
    dlg = tsguis.arithdlg(h,manager);
elseif nargin>2
    dlg = tsguis.arithdlg(h,manager,varargin{:});
end
    
%% Reset the expression
set(dlg.Handles.TXTexp,'String','')