function cmd = maskinfo(d)
%MASKINFO Returns the a cell of structures containing the mask information.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/07/18 18:15:34 $

cmd = maskinfo(get(d, 'responseTypeSpecs'), d);

% [EOF]
