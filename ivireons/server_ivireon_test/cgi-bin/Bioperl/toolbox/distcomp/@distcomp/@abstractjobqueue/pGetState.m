function val = pGetState(obj, val)
; %#ok Undocumented
%PGETState private function to get running state from java object
%
%  VAL = PGETSTATE(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:42 $ 

error('distcompy:abstractjobqueue:AbstractClassError', 'This method should be overloaded by subclasses');