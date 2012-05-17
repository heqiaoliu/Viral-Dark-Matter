function hopts = getOptshndl(h,arrayh)
%GETOPTSHNDL Get handle to frame with options.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:10:19 $

% Get handle to options frame
hopts = find(arrayh,'Tag','siggui.iirgrpdelayoptsframe');


