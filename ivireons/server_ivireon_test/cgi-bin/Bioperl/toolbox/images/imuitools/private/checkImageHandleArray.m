function checkImageHandleArray(hImage,mfilename)
%checkImageHandleArray checks an array of image handles.
%   checkImageHandleArray(hImage,mfilename) validates that HIMAGE contains a
%   valid array of image handles. If HIMAGE is not a valid array,
%   then checkImageHandles issues an error for MFILENAME.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/12/22 23:47:48 $

if ~all(ishghandle(hImage,'image'))
    eid = sprintf('Images:%s:invalidImageHandle',mfilename);
    msg = 'HIMAGE must be an array containing valid image handles.';
    error(eid,'%s',msg);
end
