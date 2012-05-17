function setData(this,fld,Value)
% Set field of private Data object

%   Author: A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:54 $


if isa(fld,'srorequirement.requirement') 
   %Passed a data object
   this.requirementObj = fld;
   this.Data           = this.requirementObj.getDataObj(this);
elseif strcmpi(fld,'data') && isa(Value,'srorequirement.requirementdata')
   %Passed a data object
   this.Data = Value;
else
   %Wrapper method to set properties of private data object
   if ishandle(this.Data)
      this.Data.(fld) = Value;
   end
end