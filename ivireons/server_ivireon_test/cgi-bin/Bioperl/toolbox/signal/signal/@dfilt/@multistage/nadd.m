function n = nadd(this)
%NADD Returns the number of adders  

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:25:40 $

n = 0;
for k=1:length(this.Stage)
    n = n + nadd(this.Stage(k));
end


% [EOF]
