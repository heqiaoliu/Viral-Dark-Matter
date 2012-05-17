function props = syncspecs(h,d)
%SYNCSPECS Properties to sync.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:10:32 $

magUnits = get(d,'magUnits');
magUnitsOpts = set(d,'magUnits');

switch magUnits,
case magUnitsOpts{1}, % 'dB'
	props = {'Apass'};
case magUnitsOpts{2}, % 'Linear'
	props = {'Epass'};
end	

% [EOF]
