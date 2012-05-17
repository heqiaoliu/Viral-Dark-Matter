function uuid = pReturnUUID(obj)
; %#ok Undocumented
%pReturnUUID 
%
%  uuid = pReturnUUID(obj)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2006/09/27 00:20:55 $ 

uuid = javaArray('net.jini.id.Uuid', numel(obj));
for i = 1:numel(obj)
    uuid(i) = obj(i).UUID;
end