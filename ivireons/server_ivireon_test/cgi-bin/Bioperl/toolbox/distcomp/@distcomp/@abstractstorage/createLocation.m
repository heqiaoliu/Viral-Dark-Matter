function location = createLocation(obj, parent, numberToCreate)
; %#ok Undocumented
%createLocation creates an empty location in the storage for an entity
%
%  LOCATION = CREATELOCATION(OBJ, PARENT)
%
% The input parent is a string without an extension, which uniquely
% identifies the parent of the locations we are trying to create

%  Copyright 2004-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:15 $

error('distcomp:abstractstorage:AbstractMethodCall', 'Storage sub-classes MUST override this method');
