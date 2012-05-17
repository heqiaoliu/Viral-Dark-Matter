function alg2obj(this,adv)
% set advanced properties 

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:54:17 $

f = fieldnames(this);

for k = 1:length(f)
    this.(f{k}) = adv.(f{k});
end
