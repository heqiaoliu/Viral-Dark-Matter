function setDescription(this,descrp)
% SETDESCRIPTION  method to set user description of a requirement
%
 
% Author(s): A. Stothert 09-Aug-2007
%   Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:28 $

for ct=1:numel(this)
   this(ct).UserDescription = descrp;
end
