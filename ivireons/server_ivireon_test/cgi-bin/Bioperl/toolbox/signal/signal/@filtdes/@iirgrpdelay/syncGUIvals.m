function syncGUIvals(h, arrayh)
%SYNCGUIVALS Sync values from frames.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:10:11 $

% Call the super's method
lpnorm_syncGUIvals(h,arrayh);

% Get handle to options frame
hopts = getOptshndl(h,arrayh);

set(h,'maxRadius',evaluatevars(get(hopts,'MaxPoleRadius')));
set(h,'initDen',evaluatevars(get(hopts,'InitDen'))); 

hf = find(arrayh,'Tag','siggui.filterorder');
set(h,'order',evaluatevars(get(hf,'order')));
