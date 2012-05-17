function h = arithdlg(varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Arithmatic dialog constructor. Optional args is the name of selected
%% time series
mlock
persistent dlg;

if nargin==0
    if isempty(dlg) || ~ishandle(dlg)
        h = tsguis.arithdlg;
    else
        h = dlg;       
    end
    return
else
    tsparentnode = varargin{1};
    manager = varargin{2};
end

%% If necessary build the arithmatic dialog
if isempty(dlg) || ~ishandle(dlg) 
    dlg = tsguis.arithdlg;
    dlg.initialize(manager,varargin{3:end});
end

%% If specified - select the defined time series
if nargin>=3 && ~isempty(varargin{3})
    dlg.update(varargin{3});
else 
    dlg.update;
end
    
%% Show the dialog
dlg.Visible = 'on';
centerfig(dlg.Figure,0);
set(dlg.Handles.TXTexp,'String','')
figure(double(dlg.Figure))

%% Return the handle
h = dlg;