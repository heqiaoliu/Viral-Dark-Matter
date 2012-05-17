function thisloadobj(this, s)
%THISLOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:20:31 $

set(this, ...
    'SpecifyDataWindowAs', s.SpecifyDataWindowAs, ...
    'CombineMethod',       s.CombineMethod);

if strcmpi(this.SpecifyDataWindowAs,'TimeBW'),
    set(this, 'TimeBW', s.TimeBW);
else
    set(this, ...
        'DPSS',           s.DPSS, ...
        'Concentrations', s.Concentrations);
end

% [EOF]
