function value = getStorageLocationStruct(obj) %#ok<STOUT,INUSD>
; %#ok Undocumented
% 
% Abstract method that should be overloaded by 
% subclass. Returns information about the storage in a structure.  
% Currently used by genericscheduler.getDataLocation.
% 

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2010/04/21 21:13:54 $

error('distcomp:abstractstorage:AbstractMethodCall', 'Storage sub-classes MUST override getStorageLocationStruct method');
