function amiHandleObject = isHandle(hObject)
%ISHANDLE check if hObject is a handle
%   OUT = ISHANDLE(ARGS) True if hObject is an HG Handle or a
%   double handle, false if otherwise

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/14 04:07:20 $

amiHandleObject = false;

if (ishghandle(hObject))
    amiHandleObject =  true;
elseif (ishandle(hObject))
    amiHandleObject =  true;
elseif (isobject(hObject))
        amiHandleObject =  true;    
end


% [EOF]
