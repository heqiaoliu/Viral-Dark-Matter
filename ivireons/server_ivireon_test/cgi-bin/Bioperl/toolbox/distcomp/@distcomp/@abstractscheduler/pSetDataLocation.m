function val = pSetDataLocation(obj, val)
; %#ok Undocumented

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:04 $


% What is the class of the current Storage object? Here is a cludgy way of
% getting the class constructor and calling it with the new directory
constructor = str2func(class(obj.Storage));
% Defer the setting of the DataLocation to the hidden property Storage
obj.Storage = constructor(val);
% And store nothing in this object
val = [];