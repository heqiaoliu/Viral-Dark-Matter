function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:38:13 $

examples = {{ ...
    'Design a 31th order type IV Hilbert Transformer.',...
    'd = fdesign.hilbert(''N,TW'',31,.2);', ...
    'Hd = design(d,''equiripple'', ''FilterStructure'', ''dfasymfir'');', ...
    'fvtool(Hd,''MagnitudeDisplay'',''Zero-phase'',''FrequencyRange'',''[-pi, pi)'')'}};

% [EOF]
