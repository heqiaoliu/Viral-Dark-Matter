function destroyLocation(obj, entityLocation)
; %#ok Undocumented
%destroyLocation remove a location from storage
%
%  DESTROYLOCATION(OBJ, ENTITYLOCATION)
%
% The input parent is a string without an extension, which uniquely
% identifies the parent of the locations we are trying to create

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:19 $

error('distcomp:abstractstorage:AbstractMethodCall', 'Storage sub-classes MUST override this method');
