function reloadsys(filename)
%RELOADSYS Simulink/Stateflow reload system dialog.
%   RELOADSYS(SYSNAME) Prompts the user to reload a system
% 	by closing and reopening it.
%
%   Any error which occurs while closing or reloading the model will
%   be thrown.
%

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2007/03/21 00:55:21 $

[ignore_dir,sysname] = fileparts(filename);
changed_on_disk = slInternal('getMdlFileState',sysname);
if changed_on_disk
    selected = questdlg(sprintf('%s',...
        'The file has changed on disk. Would you like to reload?'), ...
        sprintf('%s', 'Confirm'), 'Yes', 'No', 'Yes');
    if strcmp(selected, 'Yes')
        close_system(sysname, 0);
        open_system(filename);
    end
end

