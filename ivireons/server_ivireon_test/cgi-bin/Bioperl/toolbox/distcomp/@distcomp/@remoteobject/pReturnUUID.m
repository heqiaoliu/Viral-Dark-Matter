function uuid = pReturnUUID(obj)
; %#ok Undocumented
%pReturnUUID 
%
%  uuid = pReturnUUID(obj)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2006/09/27 00:21:40 $ 

uuid = javaArray('net.jini.id.Uuid', numel(obj));
for i = 1:numel(obj)
    uuid(i) = obj(i).UUID(1);
end