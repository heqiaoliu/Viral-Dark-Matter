function disp(hObj)
%DISP DISP for an hdf5.hdf5type object

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:08:38 $

if (numel(hObj) == 1)
    disp([class(hObj) ':']);
    disp(' ');
    disp(get(hObj));
else
    builtin('disp', hObj);
end



