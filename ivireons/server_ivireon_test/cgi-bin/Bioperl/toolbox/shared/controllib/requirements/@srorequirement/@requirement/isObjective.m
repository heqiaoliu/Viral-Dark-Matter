function bObjective = isObjective(this)
% Checks if requirement(s) are objectives or not
%
 
% Author(s): A. Stothert 25-Feb-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:23 $

nReq = numel(this);
bObjective = false*ones(nReq,1);
for iReq = 1:nReq
   bObjective(iReq) = this(iReq).isObjective;
end
