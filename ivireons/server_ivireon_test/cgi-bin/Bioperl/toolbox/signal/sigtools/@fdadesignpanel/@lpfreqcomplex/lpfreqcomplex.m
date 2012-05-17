function h = lpfreqcomplex
%LPFREQCOMPLEX Construct an LPFREQCOMPLEX object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:24:42 $

h = fdadesignpanel.lpfreqcomplex;

set(h, 'Fstop1', '-9600');
set(h, 'Fpass1', '-7200');
set(h, 'Fpass2', '12000');
set(h, 'Fstop2', '14400');

% [EOF]
