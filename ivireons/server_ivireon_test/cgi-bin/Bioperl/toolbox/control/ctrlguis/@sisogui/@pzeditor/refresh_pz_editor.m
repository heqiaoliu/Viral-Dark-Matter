function refresh_pz_editor(Editor)
%REFRESHEDITOR  Refreshes pzeditor

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2006/06/20 20:03:08 $

% Create editor GUI if it does not exist
if isempty(Editor.Handles)
    Editor.buildeditor;
end

% If pz editor is not the current tab, skip
idx = Editor.Handles.TabbedPane.getSelectedIndex + 1;
if idx ~= 1
    return
end

% get handles
PZTabHandles = Editor.Handles.PZTabHandles;

% Current index before refreshing fields
% Editor.idxPZ can be empty
CurrentidxPZ = Editor.idxPZ;

% set compensator table
Editor.refresh_pz_table;

% update selected rows
if ~isempty(CurrentidxPZ)
    if CurrentidxPZ <= length(Editor.CompList(Editor.idxC).PZGroup)
        Editor.idxPZ = CurrentidxPZ(1);
    else
        Editor.idxPZ = [];
        CurrentidxPZ = [];
    end
end
if ~isempty(CurrentidxPZ)
    awtinvoke(PZTabHandles.SelectionModel,'setSelectionInterval(II)',CurrentidxPZ(1)-1,CurrentidxPZ(1)-1);
    % refresh card too
    Editor.refreshpzeditfields(CurrentidxPZ(1));
else
    awtinvoke(PZTabHandles.SelectionModel,'clearSelection()');
    % refresh card too
    Editor.refreshpzeditfields([]);
end

