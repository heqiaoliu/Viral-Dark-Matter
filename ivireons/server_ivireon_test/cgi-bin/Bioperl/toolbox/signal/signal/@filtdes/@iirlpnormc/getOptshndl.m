function hopts = getOptshndl(h,arrayh)
%GETOPTSHNDL Get handle to frame with options.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/13 00:09:12 $

% Get handle to options frame
hopts = find(arrayh,'-class','siggui.iirlpnormcoptsframe');


