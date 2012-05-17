function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:38:41 $

examples = {{ ...
    'Design 50th order least-squares differentiator with a passband frequency of .4.', ...
    'h  = fdesign.differentiator(''N,Fp,Fst'',50,.4,.45);', ...
    'Hd = design(h, ''firls'', ''FilterStructure'', ''dfasymfir'');', ...
    'fvtool(Hd, ''MagnitudeDisplay'',''Magnitude'')'}};


% [EOF]
