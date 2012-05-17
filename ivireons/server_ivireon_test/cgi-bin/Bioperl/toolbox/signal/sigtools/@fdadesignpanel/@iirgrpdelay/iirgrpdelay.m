function this = iirgrpdelay
%LPNORM Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2005/06/16 08:40:50 $

this = fdadesignpanel.iirgrpdelay;

set(this, 'freqUnits', 'normalized', ...
    'FrequencyVector', '[0 0.1 1]', ...
    'FrequencyEdges', '[0 1]');

% [EOF]
