function val = pGetComputer(obj, val)
; %#ok Undocumented
%PGETCOMPUTER private function to get computer type
%
%  VAL = PGETCOMPUTER(OBJ, VAL)

%  Copyright 2007 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2007/07/31 19:53:26 $ 

proxyWorker = obj.ProxyObject;
try
    val = char(proxyWorker.getComputerMLType);
catch
    val = '';
end
