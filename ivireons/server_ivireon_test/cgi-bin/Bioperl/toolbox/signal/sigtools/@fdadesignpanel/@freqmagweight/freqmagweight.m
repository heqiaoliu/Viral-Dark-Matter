function h = freqmagweight
%FREQMAGWEIGHT  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2005/06/16 08:40:17 $

h = fdadesignpanel.freqmagweight;

set(h, 'freqUnits', 'normalized');

% [EOF]
