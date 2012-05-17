function val = pGetHostAddress(obj, val)
; %#ok Undocumented
%PGETHOSTADDRESS private function to get host IP address from java object
%
%  VAL = PGETHOSTADDRESS(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:35 $ 

error('distcomp:abstractjobqueue:AbstractClassError', 'This method should be overloaded by subclasses');