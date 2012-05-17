function retVal = getMetaClassIfValidEnumDataType(name)
%GETMETACLASSIFVALIDENUMDATATYPE  Get meta.class object for specified name
%  if it corresponds to a valid enumerated class for use with Simulink.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

retVal = [];

% Check for valid enumerated class
% (we currently only support Simulink.IntEnumType)
metaClass = Simulink.getMetaClassIfValidDataType(name);
if ((~isempty(metaClass)) && ...
    (metaClass < ?Simulink.IntEnumType))
   retVal = metaClass; 
end
