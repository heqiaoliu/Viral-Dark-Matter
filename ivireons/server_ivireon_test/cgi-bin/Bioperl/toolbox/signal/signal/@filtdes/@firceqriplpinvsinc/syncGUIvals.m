function syncGUIvals(h, d, arrayh)
%SYNCGUIVALS Sync values from frames.
%
%   Inputs:
%       h - handle to this object   
%       arrayh - array of handles to frames


%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/07/15 12:24:45 $

firceqrip_syncGUIvals(h,d,arrayh);

fr    = getoptsframe(h);
hopts = find(arrayh,'-class', fr.constructor);

set(d,'invSincFreqFactor',evaluatevars(get(hopts,'invSincFreqFactor')));
set(d,'invSincPower',evaluatevars(get(hopts,'invSincPower')));

% [EOF]
