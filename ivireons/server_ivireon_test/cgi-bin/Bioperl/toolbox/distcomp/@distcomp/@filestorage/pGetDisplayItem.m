function dataLocString = pGetDisplayItem(obj)
; %#ok Undocumented
% Returns the platform specific storage data location if there is one .
% used for object display as the DataLocation property only returns the
% currently used DataLocation.
%
%  Copyright 2007 The MathWorks, Inc.
%  $Revision $    $Date: 2007/06/18 22:12:48 $ 


if ispc
    header = 'UNIX: ';
    firstval = get(obj, 'WindowsStorageLocation');
    secondval = get(obj, 'UnixStorageLocation');
else
    header = 'PC: ';
    secondval = get(obj, 'WindowsStorageLocation');
    firstval = get(obj, 'UnixStorageLocation');    
end

if isempty(firstval) || isempty(secondval)
    % Should be the same as pGetDataLocation on the scheduler objects
    dataLocString = char(obj);
else
    dataLocString{1} = firstval;
    dataLocString{2} =  ['(' header secondval ')'];
end
