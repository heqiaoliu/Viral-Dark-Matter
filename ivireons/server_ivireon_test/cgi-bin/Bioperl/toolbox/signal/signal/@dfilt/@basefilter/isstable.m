function f = isstable(Hb)
%ISSTABLE True if the filter is stable

%   Author: J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/07/29 21:41:28 $

f = base_is(Hb, 'thisisstable');

% [EOF]
