function dataLoc = pGetDisplayItem()
; %#ok Undocumented
% 
% Abstract method that should be overloaded by 
% subclass. Gets the platform specific data location if there is one.
% used for object display as the DataLocation property only returns the
% currently used DataLocation.
% 

%  Copyright 2007 The MathWorks, Inc.

%  $Revision $    $Date: 2007/06/18 22:11:16 $ 

error('distcomp:abstractstorage:AbstractMethodCall', 'Storage sub-classes MUST override pGetPlatFormDataLocations method');
