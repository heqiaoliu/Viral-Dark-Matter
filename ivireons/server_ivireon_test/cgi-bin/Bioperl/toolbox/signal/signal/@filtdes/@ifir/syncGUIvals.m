function syncGUIvals(h, arrayh)
%SYNCGUIVALS Sync values from frames.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:20:54 $

% Call super's method
base_syncGUIvals(h, arrayh);

% Get handle to options frame
hopts = find(arrayh,'-isa','siggui.ifiroptsframe');

% Sync options
set(h,'InterpolationFactor',evaluatevars(get(hopts,'InterpolationFactor')));
set(h,'Optimization',get(hopts,'Optimization'));

% [EOF]
