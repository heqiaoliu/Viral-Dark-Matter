function h = getRequirementObject(this) 
% GETREQUIREMENTOBJECT  method to return requirement this object is a view
% of
%
 
% Author(s): A. Stothert 16-Aug-2007
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:46 $

for ct = numel(this):-1:1
   h(ct) = this(ct).requirementObj; %#ok<AGROW>
end
