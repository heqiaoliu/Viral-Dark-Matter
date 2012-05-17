function importstates(Hd,zi)
%IMPORTSTATES Import the initial conditions ZI into the States property.

% This should be a private method

%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:08:22 $

for i=1:nstages(Hd),
    importstates(Hd.Stage(i),zi{i});
end
