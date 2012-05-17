function newName = pSetName(obj, newName)
; %#ok Undocumented
%pSetName Change the name of the configuration.
%
%  config.pSetName(newName)

%  Copyright 2007 The MathWorks, Inc.

% This will throw an error if newName is already in use or if it is invalid.
distcomp.configserializer.rename(obj.Name, newName);

% The name is stored in the ActualName property.
obj.ActualName = newName;
