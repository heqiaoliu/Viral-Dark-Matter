function resetbeforefiltering = getresetbeforefiltering(h, dummy)
%GETRESETBEFOREFILTERING   Get the resetbeforefiltering.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/10/18 21:01:03 $

if h.PersistentMemory,
    resetbeforefiltering = 'off';
else
    resetbeforefiltering = 'on';
end


% [EOF]
