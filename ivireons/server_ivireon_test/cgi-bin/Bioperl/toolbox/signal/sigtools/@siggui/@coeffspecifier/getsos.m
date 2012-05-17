function out = getsos(hObj, out)
%GETSOS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/07/30 12:19:08 $

indx = getindex(hObj);
a_struct = get(hObj, 'AllStructures');

if isempty(a_struct) | ~a_struct.supportsos(indx),
    out = 'off';
end


% [EOF]
