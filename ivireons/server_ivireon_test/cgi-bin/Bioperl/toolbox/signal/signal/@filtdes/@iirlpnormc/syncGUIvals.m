function syncGUIvals(h, arrayh)
%SYNCGUIVALS Sync values from frames.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:43:10 $

% Call alternate method
super_syncGUIvals(h, arrayh);

% Get handle to options frame
hopts = getOptshndl(h,arrayh);

set(h,'maxRadius',evaluatevars(get(hopts,'MaxPoleRadius')));


