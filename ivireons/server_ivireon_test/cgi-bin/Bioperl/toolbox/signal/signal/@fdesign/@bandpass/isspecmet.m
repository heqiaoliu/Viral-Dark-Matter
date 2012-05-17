function b = isspecmet(this, Hd)
%ISSPECMET   True if the object's specification has been met by the filter.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:22:50 $

b = base_isspecmet(this, Hd, {'Astop1', '>'}, {'Apass', '<'}, {'Astop2', '>'});

% [EOF]
