function bEnabled = isEnabled(this)
% Checks enabled state of requirement(s)
%
 
% Author(s): A. Stothert 25-Feb-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:20 $

nReq = numel(this);
bEnabled = false(size(this));
for iReq = 1:nReq
   bEnabled(iReq) = this(iReq).isEnabled;
end
   
