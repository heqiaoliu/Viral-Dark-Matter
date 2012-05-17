function val = pGetHostAddress(obj, val)
; %#ok Undocumented
%PGETHOSTADDRESS private function to get host IP address from java object
%
%  VAL = PGETHOSTADDRESS(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:39:50 $ 

import java.net.InetAddress

proxyWorker = obj.ProxyObject;
try
    addresses = proxyWorker.getAllHostAddresses;
    validAddresses = cell(1, numel(addresses));
    for i = 1:numel(addresses)
        jAddress = InetAddress.getByName(addresses(i));
        if ~jAddress.isLoopbackAddress
            validAddresses{i} = char(jAddress.getHostAddress);
        end
    end
    validAddresses(cellfun('isempty', validAddresses)) = [];
    val = validAddresses;
catch
    % TODO
end
