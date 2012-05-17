function addListeners(obj, L)
; %#ok Undocumented
%ADDLISTENERS Add listeners to component store
%
%  ADDLISTENERS(OBJ, L) adds the listener vector L to the list of listeners
%  being held in the component.

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.3 $    $Date: 2006/06/27 22:38:44 $ 

obj.EventListeners = [obj.EventListeners; L(:)];