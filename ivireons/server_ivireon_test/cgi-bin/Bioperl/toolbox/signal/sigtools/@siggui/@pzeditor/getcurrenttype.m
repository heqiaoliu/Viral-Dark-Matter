function type = getcurrenttype(hObj)
%GETCURRENTTYPE Get the type of the current pole/zero

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/01/27 19:10:22 $

hPZ  = get(hObj, 'CurrentRoots');

if ~isempty(hPZ),
    type = gettype(hObj.CurrentRoots);
else
    type = '';
end

% [EOF]
