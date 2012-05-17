function h = fircband
%FIRCBAND Construct this object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:04:32 $

h = filtdes.fircband;

abstractgremez_construct(h);

set(h, 'Tag', 'Constrained Band Equiripple FIR');

% [EOF]
