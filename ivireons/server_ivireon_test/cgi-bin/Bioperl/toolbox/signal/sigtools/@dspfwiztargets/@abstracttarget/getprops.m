function p = getprops(hTar)
%GETPROPS Get the schema.prop of the non-dynamic properties.

%    This function determines which dynamic properties will be created at
%    the container level (parameter class).

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:17:46 $

p = get(classhandle(hTar), 'properties');
