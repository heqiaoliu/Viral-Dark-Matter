function base_syncGUIvals(h,arrayh)
%SYNCGUIVALS Sync values from lpfreqpassstop frame.
%
%   Inputs:
%       h - handle to this object
%       arrayh - array of handles to frames

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2009/05/23 08:15:13 $

% Get handle to frame
hf = find(arrayh,'-isa','fdadesignpanel.abstractfiltertypewfs');

% Store specs in object
set(h,'freqUnits',get(hf,'freqUnits'));
if isdynpropenab(h,'Fs'),
    set(h,'Fs',evaluatevars(get(hf,'Fs'))); % Do this after setting the freq units
end

% Call super's method. Do this last, so the auto conversion of
% frequencies doesn't occur
dm_syncGUIvals(h, arrayh);

    


