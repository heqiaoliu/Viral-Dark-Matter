function bObjective = isObjective(this)
% Checks requirement type

%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:44 $
%   Copyright 1986-2009 The MathWorks, Inc.

nReq = numel(this);
if nReq == 1
   bObjective = ~this.isConstraint;
else
   bObjective = false(nReq,1);
   for ct = 1:nReq
      bObjective(ct) = ~this(ct).isConstraint;
   end
end
