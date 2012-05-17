function updategrid(hObj)
%UPDATEGRID Syncs axis grid with the grid property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:43 $

hax = getbottomaxes(hObj);
set(hax, 'XGrid', hObj.Grid, 'YGrid', hObj.Grid);

% [EOF]
