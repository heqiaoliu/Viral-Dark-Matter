function proxies = createProxies(storage,  parentLocation, numberToCreate, constructor)
; %#ok Undocumented
%createProxies creates a new array of entities
%
%  PROXIES = CREATEPROXIES(STORAGE, NUMBER)
%


%  Copyright 2004-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/02/02 12:59:47 $

import com.mathworks.toolbox.distcomp.distcompobjects.EntityFileProxy;

if nargin < 3
    numberToCreate = 1;
end

CONSTRUCTOR_SUPPLIED = nargin > 3;

% Create the entity in the current storage.
[childLocations, IDs] = createLocation(storage, parentLocation, numberToCreate);
% Make the proxy
proxies = EntityFileProxy.createInstance(storage.StorageLocation, childLocations, IDs, storage.Serializer);
% Only store root constructors
if CONSTRUCTOR_SUPPLIED 
    % Add the requested constructor to the list of constructors
    storage.pAddConstructorToMetadata(parentLocation, constructor, IDs);
end
