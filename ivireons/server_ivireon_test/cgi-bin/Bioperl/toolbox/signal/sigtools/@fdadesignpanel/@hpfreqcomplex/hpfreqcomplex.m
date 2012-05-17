function h = hpfreqcomplex
%LPFREQCOMPLEX Construct an LPFREQCOMPLEX object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:24:33 $

h = fdadesignpanel.hpfreqcomplex;

set(h, 'Fpass1', '-9600');
set(h, 'Fstop1', '-7200');
set(h, 'Fstop2', '12000');
set(h, 'Fpass2', '14400');

% [EOF]
