function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:38:38 $

examples = {{ ...
    'Design 51th order least-squares differentiator.', ...
    'h  = fdesign.differentiator(''N'',51);', ...
    'Hd = design(h, ''firls'', ''FilterStructure'', ''dfasymfir'');', ...
    'fvtool(Hd, ''MagnitudeDisplay'',''Magnitude'')'}};


% [EOF]
