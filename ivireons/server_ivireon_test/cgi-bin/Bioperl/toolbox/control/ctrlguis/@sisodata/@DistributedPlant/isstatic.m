function boo = isstatic(this)
% Returns TRUE if model is a pure gain.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/03/26 17:21:59 $

numPlants = length(this.G);
boo = false(numPlants,1);

for cnt = 1:numPlants
    boo(cnt) = isstatic(this.G(cnt));
end