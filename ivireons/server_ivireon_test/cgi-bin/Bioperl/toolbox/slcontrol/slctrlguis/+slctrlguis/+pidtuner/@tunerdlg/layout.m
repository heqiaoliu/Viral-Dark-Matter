function layout(this)
%LAYOUT resize function of tuner dialog

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/04/21 22:05:01 $

p = get(this.Handles.Figure,'Position');
fw = p(3);  fh = p(4);
% keep minimum size with top left corner unchanged
if fw<140 || fh<30
    % get current left top
    y = p(2)+p(4);
    p(3) = max(144,fw);
    p(4) = max(30,fh);
    p(2) = y-p(4);
    set(this.Handles.Figure,'Position',p);
    fw = p(3);
    fh = p(4);
end

set(this.Handles.ButtonPanel,'Position',[0, 0, fw, 3]);
set(this.Handles.CSHButtonCONTAINER,'Position',[2,0.5,5,2]);
set(this.Handles.AutoUpdateCheckBoxCONTAINER,'Position',[max(0.01,fw-111) 0.5 50 2]);
set(this.Handles.OKButtonCONTAINER,'Position',[max(0.01,fw-61),0.5,14,2]);
set(this.Handles.CancelButtonCONTAINER,'Position',[max(0.01,fw-46),0.5,14,2]);
set(this.Handles.ApplyButtonCONTAINER,'Position',[max(0.01,fw-31),0.5,14,2]);
set(this.Handles.HelpButtonCONTAINER,'Position',[max(0.01,fw-16),0.5,14,2]);

Layout = this.Handles.CardPanel.getLayout;
if strcmpi(this.CurrentDesignMode,'basic')
    javaMethodEDT('show',Layout,this.Handles.CardPanel,'Basic');
    set(this.Handles.CardPanelCONTAINER,'Position',[2, 3.5, max(0.01,fw-4), 9]);
    this.Handles.PlotPanel.setPosition([2, 13, max(0.01,fw-4), max(0.01,fh-15)]);
    this.Handles.PlotPanel.layout;
    set(this.Handles.StatusBarPanelCONTAINER,'Position',[2, fh-2, fw-2, 2]);
else
    javaMethodEDT('show',Layout,this.Handles.CardPanel,'Advanced');
    set(this.Handles.CardPanelCONTAINER,'Position',[2, 3.5, max(0.01,fw-4), 15]);
    this.Handles.PlotPanel.setPosition([2, 19, max(0.01,fw-4), max(0.01,fh-21)]);
    this.Handles.PlotPanel.layout;
    set(this.Handles.StatusBarPanelCONTAINER,'Position',[2, fh-2, fw-2, 2]);
end
