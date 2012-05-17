function n = thisorder(this)
%THISORDER   Dispatch and recall.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/08/10 02:07:43 $

n = [];
Hd = dispatch(this);
for indx = 1:length(Hd)
    n = [n thisorder(Hd(indx))];
end

% [EOF]
