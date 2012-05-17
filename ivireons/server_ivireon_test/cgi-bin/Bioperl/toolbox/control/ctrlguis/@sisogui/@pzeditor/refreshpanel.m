function refreshpanel(Editor)
%REFRESHEDITOR  Refreshes all the panels in PZ Editor

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2006/06/20 20:03:11 $

% get current compensator index
choice = awtinvoke(Editor.Handles.ComboDispHandles.CompComboBox,'getSelectedIndex()')+1;
% if it is not a pure gain block
if choice<=length(Editor.CompList)
    awtinvoke(Editor.Handles.ComboDispHandles.CompGainLabel,'setVisible(Z)',true);
    awtinvoke(Editor.Handles.ComboDispHandles.CompGainEditor,'setVisible(Z)',true);
    awtinvoke(Editor.Handles.ComboDispHandles.CompPZLabel,'setVisible(Z)',true);
    % when no parameter block is defined, disable parameter panel
    if isempty(Editor.CompList(Editor.idxC).Parameters)
        awtinvoke(Editor.Handles.TabbedPane,'setEnabledAt(IZ)',0,true);
        awtinvoke(Editor.Handles.TabbedPane,'setEnabledAt(IZ)',1,false);
        awtinvoke(Editor.Handles.TabbedPane,'setSelectedIndex(I)',0);
    % otherwise, enable it
    else
        EnableTab = Editor.CompList(Editor.idxC).isTunable;
        if ~EnableTab
            awtinvoke(Editor.Handles.TabbedPane,'setSelectedIndex(I)',1);
        end
        awtinvoke(Editor.Handles.TabbedPane,'setEnabledAt(IZ)',0,EnableTab);
        awtinvoke(Editor.Handles.TabbedPane,'setEnabledAt(IZ)',1,true);
    end
    % update transfer function display
    Editor.refreshgain;
    % get tab index
    idx = Editor.Handles.TabbedPane.getSelectedIndex + 1;
    % show corresponding tab
    switch idx
        case 1 % PZ editor
            Editor.refresh_pz_editor;
        case 2 % Parameter editor
            Editor.refresh_para_editor;
    end
else
    % gain block is selected, disable pz editor panel
    awtinvoke(Editor.Handles.TabbedPane,'setEnabledAt(IZ)',0,false);
    awtinvoke(Editor.Handles.TabbedPane,'setEnabledAt(IZ)',1,true);
    awtinvoke(Editor.Handles.TabbedPane,'setSelectedIndex(I)',1);
    % disable gain block
    awtinvoke(Editor.Handles.ComboDispHandles.CompGainLabel,'setVisible(Z)',false);
    awtinvoke(Editor.Handles.ComboDispHandles.CompGainEditor,'setVisible(Z)',false);
    awtinvoke(Editor.Handles.ComboDispHandles.CompPZLabel,'setVisible(Z)',false);
    Editor.refresh_para_editor;
end