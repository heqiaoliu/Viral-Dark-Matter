function n = thisnstates(Hd)
%NSTATES Number of states.

%   Author(s): V. Pellissier
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:58:50 $

n = 0;
for k=1:length(Hd.Stage)
  n = n + thisnstates(Hd.Stage(k));
end
