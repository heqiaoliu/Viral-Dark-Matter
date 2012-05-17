function h = hpfreqifir
%HPFREQIFIR

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:19:50 $

h = fdadesignpanel.hpfreqifir;

set(h, 'Fstop', '2880');
set(h, 'Fpass', '3360');

% [EOF]
