function cmd = fc2_maskinfo(hObj, d)
%FC2_MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/06/25 13:17:24 $

cmd{1}.frequency  = [0 get(d, 'Fc1')];
cmd{2}.frequency  = [get(d, 'Fc1') get(d, 'Fc2')];
cmd{3}.frequency  = [get(d, 'Fc2') getnyquist(d)];

% [EOF]