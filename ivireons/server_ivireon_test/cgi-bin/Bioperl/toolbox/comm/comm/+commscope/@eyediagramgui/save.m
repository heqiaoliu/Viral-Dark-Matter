function status = save(this)
%SAVE     Save the eye diagram GUI session
%   Saves key the eye diagram GUI properties that define a session to a MAT file

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:23:00 $

if this.FirstSave
    % If never saved before, call save as first
    status = saveas(this);
else

    sessionData = struct('Type', 'Eye Diagram Scope', 'Version', this.Version);

    % Get properties to be saved
    fieldNames = getappdata(this.FigureHandle, 'SavedSessionData');

    % Populate the structure
    for p=1:length(fieldNames)
        value = get(this, fieldNames{p});
        sessionData.(fieldNames{p}) =  value;
    end

    try
        % Save the session data
        save(this.SessionName, '-mat', 'sessionData');

        % Remove dirty sign from the figure title
        set(this, 'Dirty', 0);

        status = 1;
    catch exception
        msg = ['An error occurred while saving the session file.  ',...
            'Make sure the file is not Read-only and you have ',...
            'permission to write to that directory.'];
        error(this, msg);
    end
end

%-------------------------------------------------------------------------------
% [EOF]
