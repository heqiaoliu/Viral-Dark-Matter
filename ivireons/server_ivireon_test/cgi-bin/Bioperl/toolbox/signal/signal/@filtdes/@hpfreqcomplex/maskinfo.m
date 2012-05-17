function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:20:15 $

cmd = abstract_maskinfo(hObj, d);

cmd{1}.frequency(1) = -getnyquist(d);

% [EOF]
