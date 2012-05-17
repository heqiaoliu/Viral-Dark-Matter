function keys = pConvertProxiesToKeys(root, proxies)
; %#ok Undocumented
%pConvertProxiesToKeys convert proxies to relevant keys
%
%  [KEYS] = pConvertProxiesToKeys(ROOT, PROXIES)
% 
% This is a private function to take an array of proxies and make sure they
% are converted to relevant keys for use in the caching mechanisms.

%  Copyright 2004-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/03/31 17:07:49 $ 

% What are we converting - if it is already a UUID then leave it as such,
% otherwise assume it is something which implements a getID method and call
% that.
if isa(proxies, 'net.jini.id.Uuid') || isa(proxies, 'net.jini.id.Uuid[]')
    keys = proxies;
else
    if ~isempty(proxies)
        % Iterate over each Proxy in reverse order to pre-allocate the array
        for i = numel(proxies):-1:1
            keys(i) = proxies(i).getID;
        end
    else
        keys = [];
    end
end
