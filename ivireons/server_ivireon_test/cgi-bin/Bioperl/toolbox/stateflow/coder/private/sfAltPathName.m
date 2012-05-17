function altPath = sfAltPathName(path)

%	Copyright 2005-2007 The MathWorks, Inc.
%------------------------------------------------------------------------------
if ispc
    altPaths = true;
    ignoreErrors = true;
    altPath = getPathName(path,altPaths,ignoreErrors);
else
    altPath = strrep(path, ' ', '\ ');
end
