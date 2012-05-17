function [proxy, constructor] = getProxyByName(storage, entityLocation)
; %#ok Undocumented
%getProxyByName 
%
%  [PROXY, CONSTRUCTOR] = GETPROXYBYNAME(STORAGE, LOCATION)
%
% 

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:23 $

import com.mathworks.toolbox.distcomp.distcompobjects.EntityFileProxy;

% Get the ID of the entity
ID = pGetIDByName(storage, entityLocation);
% Make the proxy
proxy = EntityFileProxy.createInstance(storage.StorageLocation, entityLocation, ID, storage.Serializer);
% Only check the constructors if asked
if nargout > 1 
    parent = storage.pGetParentLocationFromEntityLocation(entityLocation);
    constructor = storage.pGetConstructorsFromMetadata(parent, ID);
end