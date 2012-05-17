function openppt(file)
%OPENPPT Opens a Microsoft PowerPoint file.

% Copyright 1984-2007 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2007/11/13 00:08:31 $

try
    if ispc
        winopen(file)
    elseif strncmp(computer,'MAC',3);
        unix(['open "' file '" &']);
    else
        edit(file);
    end
catch exception %#ok
    edit(file)
end
