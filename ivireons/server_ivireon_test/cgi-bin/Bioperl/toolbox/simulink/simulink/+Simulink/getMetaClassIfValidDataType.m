function retVal = getMetaClassIfValidDataType(name)
%GETMETACLASSIFVALIDDATATYPE  Get meta.class object for specified name
%  if it corresponds to a valid MATLAB class for use with Simulink.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

assert(isvarname(name));
retVal = [];

% Check for valid class for use with Simulink
% (we currently only support Simulink.IntEnumType)
metaClass = meta.class.fromName(name);
if ((~isempty(metaClass)) && ...
    (metaClass < ?Simulink.IntEnumType))
   retVal = metaClass; 
end
