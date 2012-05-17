function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:14:56 $

% Prop name, data type, default value, listener callback
specs(1) = cell2struct({'Wpass1', 'udouble', 1, [], 'magspec'}, specfields(h), 2);
specs(2) = cell2struct({'Wstop1', 'udouble', 1, [], 'magspec'}, specfields(h), 2);
specs(3) = cell2struct({'Wpass2', 'udouble', 1, [], 'magspec'}, specfields(h), 2);
specs(4) = cell2struct({'Wstop2', 'udouble', 1, [], 'magspec'}, specfields(h), 2);
specs(5) = cell2struct({'Wpass3', 'udouble', 1, [], 'magspec'}, specfields(h), 2);

% [EOF]
