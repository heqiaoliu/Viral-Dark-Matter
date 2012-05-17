function status = saveas(this)
%SAVEAS   Save the eye diagram GUI session after asking for file name
%   Saves key the eye diagram GUI properties that define a session to a MAT file
%   after asking for file name.

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:23:02 $


[filename pathname] = uiputfile({'*.eds', 'Eye Diagram Scope (*.eds)'}, ...
    'Save Eye Diagram Scope Session', this.SessionName);
if filename
    % Store the last valid file location
    this.LastSessionFileLocation = pathname;

    % Store the session name
    this.SessionName = fullfile(pathname, filename);

    % Clear the first save flag
    set(this, 'FirstSave', 0);
    
    % File name returned
    status = 1;
else
    % Cancel selected
    status = 0;
    return
end

save(this);

%-------------------------------------------------------------------------------
% [EOF]
