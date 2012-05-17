function loadObject(this,savedObject) 
% LOADOBJECT  Method restore object properties from a saved object
%
 
% Author(s): A. Stothert 09-Aug-2007
%   Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:25 $

this.Data   = savedObject.Data;
this.Source = savedObject.Source;

saveData = savedObject.fldData;   
fldNames = fieldnames(saveData);
for ct = 1:numel(fldNames)
   if isprop(this,fldNames{ct})
      set(this,fldNames{ct},saveData.(fldNames{ct}))
   end
end
