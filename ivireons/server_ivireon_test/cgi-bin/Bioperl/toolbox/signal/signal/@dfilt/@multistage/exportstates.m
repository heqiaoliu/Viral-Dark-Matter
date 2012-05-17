function zf = exportstates(Hd)
%EXPORTSTATES Export the final conditions.

% This should be a private method

%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:08:04 $

zf = {};
for i=1:nstages(Hd),
    zf{i} = exportstates(Hd.Stage(i));
end
