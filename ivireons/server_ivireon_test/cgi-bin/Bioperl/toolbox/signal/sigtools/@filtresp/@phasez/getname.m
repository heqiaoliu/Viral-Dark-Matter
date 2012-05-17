function out = getname(hObj, out)
%GETNAME Get the name of the magnitude response

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/28 19:34:32 $

phase = get(hObj, 'PhaseDisplay');

out = [phase ' Response'];
    
% [EOF]
