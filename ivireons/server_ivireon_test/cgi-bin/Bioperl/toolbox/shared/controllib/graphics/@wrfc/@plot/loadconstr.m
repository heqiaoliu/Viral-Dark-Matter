function loadconstr(Plot,SavedData)
%LOADCONSTR  Reloads saved constraint data.

%   Author(s): A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:29:31 $

% Clear existing constraints
delete(Plot.findconstr);

% Create and initialize new constraints
for ct=1:length(SavedData),
    % Use Editor.newconstr to recreate the constraint, this creates a
    % constraint editor
    cEditor = Plot.newconstr(SavedData(ct).Type);
    % From the constraint editor construct a view
    hC = cEditor.Requirement.getView(Plot);
    hC.load(SavedData(ct).Data);
    hC.PatchColor = Plot.Options.RequirementColor;
    % Add to constraint list (includes rendering)
    Plot.addconstr(hC);
    % Unselect
    hC.Selected = 'off';
end


