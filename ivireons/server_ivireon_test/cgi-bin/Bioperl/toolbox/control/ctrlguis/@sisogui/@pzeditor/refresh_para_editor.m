function refresh_para_editor(Editor)
%REFRESHEDITOR  Refreshes parameter editor

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/04/30 00:36:56 $

% Create editor GUI if it does not exist
if isempty(Editor.Handles)
    Editor.buildeditor;
end

% If pz editor is not the current tab, skip
idx = Editor.Handles.TabbedPane.getSelectedIndex + 1;
if idx ~= 2
    return
end

% get handles
ParaTabHandles = Editor.Handles.ParaTabHandles;
% Current index before refreshing fields
if ParaTabHandles.Table.getSelectedRow == -1
    CurrentidxPara = [];
else
    CurrentidxPara = ParaTabHandles.Table.getSelectedRow + 1;
end

% set compensator table
Editor.refresh_para_table;

% update selection
SelectionModel = ParaTabHandles.Table.getSelectionModel;
if ~isempty(CurrentidxPara)
    awtinvoke(SelectionModel,'setSelectionInterval(II)',CurrentidxPara-1,CurrentidxPara-1);
else
    awtinvoke(SelectionModel,'clearSelection()');
end

