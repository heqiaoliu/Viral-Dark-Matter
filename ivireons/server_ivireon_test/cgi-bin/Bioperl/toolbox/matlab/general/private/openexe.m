function openexe(file)
%OPENEXE Opens a Microsoft DOS or Windows executable.

% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2007/11/13 00:08:30 $

if ispc
    try
        winopen(file)
    catch exception %#ok
        edit(file)
    end
else
    edit(file)
end