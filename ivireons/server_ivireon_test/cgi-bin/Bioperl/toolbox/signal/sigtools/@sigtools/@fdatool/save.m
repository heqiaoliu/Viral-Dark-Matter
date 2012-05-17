function success = save(hFDA, filename)
%SAVE Save the current session

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2008/05/31 23:28:41 $

overwrite = get(hFDA, 'Overwrite');

if nargin == 1, filename = get(hFDA, 'filename'); end
if nargin == 2, set(hFDA, 'OverWrite', 'On'); end

[file, ext] = strtok(filename, '.');

if isempty(ext),
    filename = [file '.fda'];
end

success = false;

if strcmpi(hFDA.OverWrite, 'Off'),
    success = saveas(hFDA);
elseif file ~= 0,
    
    success = true;

    % Unix returns a path that sometimes includes two paths (the
    % current path followed by the path to the file) separated by '//'.
    % Remove the first path.
    indx = findstr(filename,[filesep,filesep]);
    if ~isempty(indx)
        filename = filename(indx+1:end);
    end

    s = getstate(hFDA); %#ok

    try
        save(filename,'s','-mat');
        set(hFDA, ....
            'FileName', filename, ...
            'FileDirty', 0, ...
            'OverWrite', 'On');

    catch
        set(hFDA, 'Overwrite', overwrite);
        errStr = ['An error occurred while saving the session file.  ',...
            'Make sure the file is not Read-only and you have ',...
            'permission to write to that directory.'];
        if ~isempty(errStr), error(generatemsgid('SigErr'),errStr); end
    end
end

% [EOF]
