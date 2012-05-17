function bool = validate_filename(hEH)
%VALIDATE_FILENAME Get a new filename

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/13 00:23:13 $

% This should be private

bool = true;

[filename, pathname] = uiputfile( ...
    {'*.h;', 'Header Files (*.h)'}, ...
    'Save as', hEH.FileName);

% If filename is not 0 then a file has been chosen
if filename ~= 0
    
    % Make sure the user enters a file with the .h extension
    [file ext] = strtok(filename,'.');
    if ~strcmpi(ext,'.h')
        filename = [file '.h'];
    end
    
    file = strcat(pathname,filename);
    set(hEH, 'Filename', file);
else
    bool = false;
end

% [EOF]
