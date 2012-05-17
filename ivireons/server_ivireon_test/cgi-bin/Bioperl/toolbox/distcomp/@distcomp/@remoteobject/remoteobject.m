function remoteobject(obj, UUID)
; %#ok Undocumented
%REMOTEOBJECT A short description of the function
%
%  OBJ = REMOTEOBJECT(ID)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:38:47 $ 

% This is an abstract constructor so any calls that attempt to construct a
% real distcomp.remoteobject will fail

if isa(UUID, 'net.jini.id.Uuid')
    array = javaArray('net.jini.id.Uuid', 1);
    array(1) = UUID;
elseif isa(UUID, 'net.jini.id.Uuid[]')
    array = UUID;        
end
obj.UUID = array;
