function [proxies, constructors] = findProxies(storage, parentLocation)
; %#ok Undocumented
%findProxies 
%
%  PROXIES = FINDPROXIES(STORAGE, PARENTLOCATION)
%
% 

%  Copyright 2004-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:21 $

import com.mathworks.toolbox.distcomp.distcompobjects.EntityFileProxy;

% Create the entity in the current storage.
[entityLocations, IDs] = getEntityLocations(storage, parentLocation);
% Make the proxy
proxies = EntityFileProxy.createInstance(storage.StorageLocation, entityLocations, IDs, storage.Serializer);
% Only check the constructors if asked
if nargout > 1 
    constructors = storage.pGetConstructorsFromMetadata(parentLocation, IDs);
end