function cmd = fc1_maskinfo(hObj, d)
%FC1_MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/06/25 13:17:25 $

cmd{1}.frequency  = [0 get(d, 'Fc')];
cmd{2}.frequency  = [get(d, 'Fc') getnyquist(d)];

% [EOF]
