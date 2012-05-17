function val = pGetIsRunning(obj, val)
; %#ok Undocumented
%PGETISRUNNING private function to get running state from java object
%
%  VAL = PGETISRUNNING(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:40 $ 

error('distcomp:abstractjobqueue:AbstractClassError', 'This method should be overloaded by subclasses');