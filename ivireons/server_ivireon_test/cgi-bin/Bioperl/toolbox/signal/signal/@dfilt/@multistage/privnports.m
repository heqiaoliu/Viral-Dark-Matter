function n = privnports(this)
%PRIVNPORTS Number of input ports of the realizemdl model

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/04/09 19:05:11 $

n = 1; % Default
for k = 1:length(this.Stage)
    n = n + privnports(this.Stage(k))-1;
end

% [EOF]
