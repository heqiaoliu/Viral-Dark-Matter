function opendoc(file)
%OPENDOC Opens a Microsoft Word file.

% Copyright 1984-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2007/11/13 00:08:29 $

if ispc
    try
        winopen(file)
    catch exception %#ok
        edit(file)
    end
else
    edit(file)
end