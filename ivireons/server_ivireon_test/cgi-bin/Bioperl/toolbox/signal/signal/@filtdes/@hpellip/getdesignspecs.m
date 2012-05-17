function [Fpass, Apass, Astop] = getdesignspecs(h, d)
%GETDESIGNSPECS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/04 18:12:45 $

% Get frequency specs, they have been prenormalized
Fpass = get(d,'Fpass');

% Set the magUnits temporarily to 'dB' to get attenuation
magUnits = get(d,'magUnits');
set(d,'magUnits','dB');
Apass = get(d,'Apass');
Astop = get(d,'Astop');
set(d,'magUnits',magUnits);

% [EOF]
