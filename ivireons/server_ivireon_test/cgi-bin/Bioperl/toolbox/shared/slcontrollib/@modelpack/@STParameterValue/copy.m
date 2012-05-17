function newObj = copy(this) 
% COPY  method to make a copy of this object
%
 
% Author(s): A. Stothert 06-Nov-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:01:52 $ 

for ct=numel(this):-1:1
   newObj(ct) = modelpack.STParameterValue;
   newObj(ct).ID                  = this(ct).ID;
   newObj(ct).Name                = this(ct).Name;
   newObj(ct).Dimension           = this(ct).Dimension;  %This must get copied before values are set
   newObj(ct).isDimensionEditable = this(ct).isDimensionEditable;
   newObj(ct).Format              = this(ct).Format;
   newObj(ct).Value               = this(ct).Value;
end