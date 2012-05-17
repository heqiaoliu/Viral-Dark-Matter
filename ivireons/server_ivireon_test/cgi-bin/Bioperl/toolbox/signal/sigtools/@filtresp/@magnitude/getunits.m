function units = getunits(this)
%GETUNITS   Get the units.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:41:41 $

hprm = getparameter(this, 'unitcircle');

Hd = get(this, 'Filters');

switch find(strcmpi(hprm.Value, hprm.ValidValues))
    case {1, 3}
        [y,e,units] = engunits(getmaxfs(Hd)/2);
    case 2
        [y,e,units] = engunits(getmaxfs(Hd));
    case 4
        [y,e,units] = engunits(this.FrequencyVector);
end

units = [units 'Hz'];

% [EOF]
