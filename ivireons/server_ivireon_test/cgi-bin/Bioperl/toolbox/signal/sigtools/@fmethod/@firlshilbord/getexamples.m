function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:38:45 $

examples = {{ ...
    'Design a 30th order type III Hilbert Transformer.',...
    'd = fdesign.hilbert(''N,TW'',30,.2);', ...
    'Hd = design(d,''firls'', ''FilterStructure'', ''dfasymfir'');', ...
    'fvtool(Hd,''MagnitudeDisplay'',''Zero-phase'',''FrequencyRange'',''[-pi, pi)'')'}};


% [EOF]
