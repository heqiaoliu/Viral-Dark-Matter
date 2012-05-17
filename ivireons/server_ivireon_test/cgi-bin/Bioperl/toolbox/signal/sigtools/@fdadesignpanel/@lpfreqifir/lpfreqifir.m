function h = lpfreqifir
%LPFREQIFIR

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:19:54 $

h = fdadesignpanel.lpfreqifir;

set(h, 'Fpass', '2880');
set(h, 'Fstop', '3360');

% [EOF]
