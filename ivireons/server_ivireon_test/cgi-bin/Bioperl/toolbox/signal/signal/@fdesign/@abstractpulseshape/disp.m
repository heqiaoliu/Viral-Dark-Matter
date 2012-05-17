function disp(this)
%DISP   Display the design object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:00:15 $

s = get(this);
s = reorderstructure(s, 'Response', 'SamplesPerSymbol', ...
    'Specification', 'Description');

if s.NormalizedFrequency
    s = rmfield(s, 'Fs');
end

siguddutils('dispstr', s);

% [EOF]
