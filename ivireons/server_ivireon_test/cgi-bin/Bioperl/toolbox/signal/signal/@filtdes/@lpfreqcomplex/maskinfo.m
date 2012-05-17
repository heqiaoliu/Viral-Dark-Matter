function cmd = maskinfo(hObj, d)
%MASKINFO Returns the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:21:56 $

cmd = abstract_maskinfo(hObj, d);

cmd{1}.frequency(1) = -getnyquist(d);

% [EOF]
