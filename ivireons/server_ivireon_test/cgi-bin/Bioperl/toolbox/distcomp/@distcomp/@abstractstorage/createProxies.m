function proxies = createProxies(storage,  parentLocation, numberToCreate, constructor)
; %#ok Undocumented
%createProxies creates a new array of entities
%
%  PROXIES = CREATEPROXIES(STORAGE, NUMBER)
%


%  Copyright 2004-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:17 $

error('distcomp:abstractstorage:AbstractMethodCall', 'Storage sub-classes MUST override this method');
