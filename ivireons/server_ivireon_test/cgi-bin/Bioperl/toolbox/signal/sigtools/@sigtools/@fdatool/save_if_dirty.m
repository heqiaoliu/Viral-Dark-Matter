function status = save_if_dirty(hFDA, action)
% SAVE_IF_DIRTY Query the user to save if GUI is dirty.
%
% Inputs:
%     hFDA - handle to FDATool
%     action - 'closing', or 'loading' file.
% Output:
%     status = 1 if Yes, No, or UIs not dirty.
%     status = 0 if Cancel.
%

%   Author(s): P. Pacheco, R. Losada, P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2007/12/14 15:21:20 $

% This should be a private method

if ~hFDA.FileDirty,
    status = 1;       % Proceed as normal
    return
end

% Removes the path and any extension
[path, file] = fileparts(get(hFDA, 'FileName'));

% If changes have not been saved, warn (prompt) user
ansBtn = questdlg({sprintf('Save %s session before %s?',file,action)},'FDATool','Cancel');

switch ansBtn,
case 'Yes',
    status = save(hFDA);
case 'No'
    status = 1;
    % User didn't save, reset dirty flag so opened file is not dirty
    hFDA.FileDirty = 0;
case 'Cancel'        
    status = 0;
end

% [EOF]
