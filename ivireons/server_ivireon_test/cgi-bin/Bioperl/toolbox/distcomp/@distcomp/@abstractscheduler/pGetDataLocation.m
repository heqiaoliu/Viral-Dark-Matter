function val = pGetDataLocation(obj, val)
; %#ok Undocumented

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:34:56 $

% This is a string representation of the actual storage property
val = char(obj.Storage);