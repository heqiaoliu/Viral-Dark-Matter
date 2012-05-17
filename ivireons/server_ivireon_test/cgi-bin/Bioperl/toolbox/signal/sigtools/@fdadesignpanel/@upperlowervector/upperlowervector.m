function h = upperlowervector
%UPPERLOWERVECTOR Construct a UPPERLOWERVECTOR object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:24:59 $

h = fdadesignpanel.upperlowervector;

set(h, 'FreqUnits', 'normalized');
set(h, 'FrequencyVector', '[0 .4 .5 1]');

% [EOF]
