function saveObject = getSaveObject(this) 
% GETSAVEOBJECT  method to convert object to a saveable object
%
 
% Author(s): A. Stothert 09-Aug-2007
%   Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:16 $

fldStruct = struct(this);
if isfield(fldStruct,'Description')
   fldStruct = rmfield(fldStruct,'Description'); 
end
saveObject = srorequirement.saveobject(...
   class(this),...
   fldStruct, ...
   this.Source,...
   this.Data);

