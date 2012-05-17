function [found, objects] = findObjectInHashtable(root, proxies)
; %#ok Undocumented
%findObjectInHashtable attempt to find the proxies in the hashtable
%
%  [FOUND, OBJS] = findObjectInHashtable(ROOT, PROXIES)
% 
% This is a private function to take an array of proxies and check if they
% already exist in the cached hash table

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:38:17 $ 

% How many are there
numObjects = numel(proxies);
% Predefine the output size - with invalid handles
objects = handle(-ones(numObjects, 1));
found = false(size(objects));
% Get the hashtable from the root
proxyHashtable = root.ProxyHashtable;
% Convert the proxies to keys for use in the hashtable
keys = root.pConvertProxiesToKeys(proxies);
% Iterate over each Proxy in turn
for i = 1:numObjects
    % Have we already got this one registered in our list
    obj = handle(proxyHashtable.get(keys(i)));
    % Found one so fill in the output fields
    if ~isempty(obj)
        objects(i) = obj;
        found(i) = true;
    end
end
