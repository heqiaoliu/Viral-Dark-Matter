function Hcopy = copy(this)
%COPY   Copy this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:20:17 $

% LOADOBJ and COPY perform the same actions.
Hcopy = loadobj(this);

% [EOF]
