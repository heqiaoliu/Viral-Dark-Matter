function status = saveIfDirty(this, action)
%SAVEIFDIRTY Check if the GUI is dirty and prompt for save

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:23:01 $

if ~this.Dirty,
    status = 1;       % Proceed as normal
    return
end

% Removes the path and any extension
[path, file] = fileparts(get(this, 'SessionName'));

% If changes have not been saved, warn (prompt) user
ansBtn = questdlg({sprintf('Save %s session before %s?',file,action)},...
    'Eye Scope','Cancel');

if ~isempty(ansBtn)
    % If the question dialog box is closed using ALT-F4 or "x" then ansBtn is
    % returned as empty array.  Make sure that it is not empty.  If empty,
    % threat as is cancel was selected.
    switch ansBtn,
        case 'Yes',
            status = save(this);
        case 'No'
            status = 1;
        case 'Cancel'
            status = 0;
    end
else
    status = 0;
end
%-------------------------------------------------------------------------------
% [EOF]
