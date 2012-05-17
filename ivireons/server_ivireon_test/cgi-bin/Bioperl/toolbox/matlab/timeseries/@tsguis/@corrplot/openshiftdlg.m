function openshiftdlg(h)

% Copyright 2004-2008 The MathWorks, Inc.

%% Show the (singleton) selection dialog

persistent dlg;

%% If necessary build the shift dialog
if isempty(dlg) || ~ishandle(dlg) || isempty(dlg.Figure) || ...
        ~ishghandle(dlg.Figure)
    dlg = tsguis.shiftdlg;
    %% Target the dialog and show it
    set(dlg,'Viewnode',h.Parent);
    dlg.initialize
    centerfig(dlg.Figure,0);
end

%% Target the dialog and show it
dlg.ViewNode = h.Parent;
dlg.Visible = 'on';
figure(double(dlg.Figure))
 
