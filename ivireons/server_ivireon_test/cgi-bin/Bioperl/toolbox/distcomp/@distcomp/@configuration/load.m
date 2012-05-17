function load(obj)
; %#ok Undocumented
%load Loads all the properties in this configuration.
%

%  Copyright 2007 The MathWorks, Inc.

% Load all the values in a single call to the serializer, then unpack everything
% and send into the sections.
allValues = distcomp.configserializer.load(obj.ActualName);
obj.pSetFromStruct(allValues);
