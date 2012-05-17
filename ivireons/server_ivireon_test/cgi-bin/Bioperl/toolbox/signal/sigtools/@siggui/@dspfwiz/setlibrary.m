function out = setlibrary(hObj, out)
%SETLIBRARY Check if the library is valid

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:18:27 $

hPrm = get(hObj, 'Parameter');
libs = libraries(hPrm);
indx = strmatch(out, libs);

switch length(indx)
case 0
    error(generatemsgid('NotSupported'),'Library not found.');
case 1
    out = libs{indx};
otherwise, % More than 1 match
    error(generatemsgid('GUIErr'),'More than one matching library found.');
end

% EOF
