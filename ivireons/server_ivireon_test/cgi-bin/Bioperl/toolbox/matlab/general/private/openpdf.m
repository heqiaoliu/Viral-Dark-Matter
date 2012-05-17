function openpdf(fileName)
%OPENPDF Opens a PDF file in the appropriate viewer/editor.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2009/05/23 08:03:10 $

if ~exist(fileName, 'file')
    error('MATLAB:openpdf:noSuchFile', 'The file %s does not exist.',fileName);
end

if ispc
    winopen(fileName);
elseif strncmp(computer,'MAC',3) 
    unix(['open "' fileName '" &']);
else
    command = 'acroread';
    if (usejava('mwt') == 1)
        % Get the user's PDF reader from preferences.
        command = com.mathworks.services.Prefs.getStringPref('HelpPDF_Reader', command);
        command = char(command);
    end
    unix([command ' "' fileName '" &']);
end






