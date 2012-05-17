function mv = set_magnitudevector(this, mv)
%SET_MAGNITUDEVECTOR   PreSet function for the 'magnitudevector' property.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:10:25 $

switch lower(this.MagnitudeUnits)
    case 'linear'
        % NO OP.
    case 'db'
        mv = 10.^(mv./20);
    case 'squared'
        mv = sqrt(mv);
        
end

set(this, 'privMagnitudeVector', mv);

mv = [];

% [EOF]
