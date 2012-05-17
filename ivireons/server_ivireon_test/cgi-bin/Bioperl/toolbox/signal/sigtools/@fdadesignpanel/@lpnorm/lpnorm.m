function this = lpnorm(varargin)
%LPNORM Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2008/01/29 15:39:23 $

this = fdadesignpanel.lpnorm;

f = '[0 0.37 0.399 0.401 0.43 1]';
set(this, 'freqUnits', 'normalized', ...
    'FrequencyVector', f, 'FrequencyEdges', f);

% [EOF]
