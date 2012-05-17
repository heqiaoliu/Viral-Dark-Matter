function syncGUIvals(h, arrayh)
%SYNCGUIVALS Sync values from frames.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/03/02 10:23:10 $

% Call super's method
super_syncGUIvals(h, arrayh);

% Get handle to options frame
hopts = find(arrayh,'-isa','siggui.remezoptionsframe');

% Sync options
set(h,'DensityFactor',evaluatevars(get(hopts,'DensityFactor')));

