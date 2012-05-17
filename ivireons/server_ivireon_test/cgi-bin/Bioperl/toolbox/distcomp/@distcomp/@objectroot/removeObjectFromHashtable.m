function found = removeObjectFromHashtable(root, proxies)
; %#ok Undocumented
%removeObjectFromHashtable attempt to remove objects from the hashtable
%
%  found = removeObjectFromHashtable(ROOT, PROXIES)
% 

%  Copyright 2006 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2006/09/27 00:21:33 $ 

% Get the hashtable from the root
proxyHashtable = root.ProxyHashtable;
% Convert the proxies to keys for use in the hashtable
keys = root.pConvertProxiesToKeys(proxies);
found = false(numel(proxies), 1);
% Iterate over each Proxy in turn
for i = 1:numel(proxies)
    % Remove this one
    found(i) = ~isempty(proxyHashtable.remove( keys(i) ));
end