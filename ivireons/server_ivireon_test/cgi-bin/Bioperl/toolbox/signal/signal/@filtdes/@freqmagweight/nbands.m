function n = nbands(h, d)
%NBANDS Returns the number of bands

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:07:08 $

n = length(d.FrequencyVector)/2;

% [EOF]
