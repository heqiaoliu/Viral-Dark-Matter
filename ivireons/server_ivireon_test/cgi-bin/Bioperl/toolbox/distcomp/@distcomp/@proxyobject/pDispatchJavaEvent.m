function pDispatchJavaEvent(obj, src, event)
; %#ok Undocumented
%pDispatchJavaEvent private function to dispatch java events to udd objects
%
%  

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:38:33 $ 

warning('distcomp:proxyobject:InvalidCall', 'This method should have been overloaded by derived classes');
