function proxyobject(obj, proxyObject)
; %#ok Undocumented
%PROXYOBJECT A short description of the function
%
%  PROXYOBJECT(OBJ, PROXYOBJECT)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/06/24 17:01:49 $ 

obj.IsBeingConstructed = true;
% If our proxy is a UUID then we will have to get our proxy object from
% somewhere up the tree when we are connected to something.
if isa(proxyObject, 'net.jini.id.Uuid')
    obj.ProxyObject = [];
    obj.remoteobject(proxyObject);
    % Listen for being connected to something and set our proxy when that
    % happens
    l = handle.listener(obj, 'ObjectParentChanged', @pSetMyProxyObject);
    obj.EventListeners = [obj.EventListeners ; l];
else
    obj.ProxyObject = proxyObject;
    obj.remoteobject(proxyObject.getID);
    % Tell sub-classes that we really do have proxyObject
    obj.HasProxyObject = true;
end
