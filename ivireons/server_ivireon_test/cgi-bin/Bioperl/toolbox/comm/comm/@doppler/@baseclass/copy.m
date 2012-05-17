function Hcopy = copy(this)
%COPY   Copy this object.

%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/14 15:02:23 $

for i=1:length(this)
    Hcopy(i) = loadobj(this(i));
end

