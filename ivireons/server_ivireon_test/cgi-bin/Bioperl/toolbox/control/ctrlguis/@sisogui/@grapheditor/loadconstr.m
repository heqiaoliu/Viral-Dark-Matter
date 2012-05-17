function loadconstr(Editor,SavedData)
%LOADCONSTR  Reloads saved constraint data.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2009/02/06 14:16:30 $

% Clear existing constraints
delete(Editor.findconstr);

% Create and initialize new constraints
for ct=1:length(SavedData),
    % Use Editor.newconstr to recreate the constraint, this creates a 
    % constraint editor
    cEditor = Editor.newconstr(SavedData(ct).Type);
    % From the constraint editor construct a view
    sisodb = Editor.up;
    hC = cEditor.Requirement.getView(Editor);
    hC.PatchColor = sisodb.Preferences.RequirementColor;
    hC.load(SavedData(ct).Data);
	% Add to constraint list (includes rendering)
	Editor.addconstr(hC);
    % Unselect
    hC.Selected = 'off';
end

% Update limits
updateview(Editor)
