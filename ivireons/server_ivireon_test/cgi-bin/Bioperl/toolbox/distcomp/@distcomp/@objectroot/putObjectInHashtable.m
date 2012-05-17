function putObjectInHashtable(root, proxies, objects)
; %#ok Undocumented
%putObjectInHashtable attempt to put the proxies in the hashtable
%
%  putObjectInHashtable(ROOT, PROXIES, OBJECTS)
% 

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:38:20 $ 

% How many are there
numObjects = numel(proxies);

if ~isequal(numObjects, numel(objects))
    error('distcomp:objectroot:InvalidArgument', 'The number of proxies and objects must be identical');
end

% Get the hashtable from the root
proxyHashtable = root.ProxyHashtable;
% Convert the proxies to keys for use in the hashtable
keys = root.pConvertProxiesToKeys(proxies);
% Iterate over each Proxy in turn
for i = 1:numObjects
    % Put this one in
    proxyHashtable.put( keys(i), java(objects(i)) );
end