function name = clone(obj)
; %#ok Undocumented
%clones this object using an available name for the new configuration.

%   Copyright 2007 The MathWorks, Inc.

% Let the names be name.copy1, name.copy2, etc.
% The serializer will add the numeric suffix.
proposedName = sprintf('%s.copy', obj.Name);
% Copy all the data of this object.
newName = distcomp.configserializer.clone(obj.Name, proposedName);

% Create a new object based on the copy.
conf = distcomp.configuration;
conf.pInitializeFromName(newName);

name = conf.ActualName;
