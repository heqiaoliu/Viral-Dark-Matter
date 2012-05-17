function val = pGetName(obj, val) %#ok<INUSD>
; %#ok Undocumented
%PGETNAME private function to get jobmanager name from cached name
%
%  VAL = PGETNAME(OBJ, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2008/10/02 18:40:36 $ 

val = obj.CachedName;
