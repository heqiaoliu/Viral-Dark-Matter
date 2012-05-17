function Hd = reffilter(this)
%REFFILTER   Return the reference filter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/02/09 08:41:40 $

% Loop over and make a copy.
for indx = 1:length(this)
    Hd(indx) = copy(this);
end

% [EOF]
