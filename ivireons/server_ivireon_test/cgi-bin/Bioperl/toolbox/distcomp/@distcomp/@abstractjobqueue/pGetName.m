function val = pGetName(obj, val)
; %#ok Undocumented
%PGETNAME private function to get jobmanager name from java object
%
%  VAL = PGETNAME(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:41 $ 

error('distcomp:abstractjobqueue:AbstractClassError', 'This method should be overloaded by subclasses');