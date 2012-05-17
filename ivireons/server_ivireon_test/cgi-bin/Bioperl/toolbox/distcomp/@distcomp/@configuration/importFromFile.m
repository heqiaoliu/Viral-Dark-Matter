function name = importFromFile(filename)
; %#ok Undocumented
%Constructs a new configuration using the information in the specified file.
%

%  Copyright 2007-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.7 $  $Date: 2009/04/15 22:58:18 $ 

[name, values] = distcomp.configuration.loadconfigfile( filename );

obj = distcomp.configuration;

try
    obj.ActualName = distcomp.configserializer.createNew(sprintf('%s.import', name), name);
    findResourceType = obj.pGetTypeFromStruct(values, name);
    obj.pConstructFromClassTypes(findResourceType);
    obj.pSetFromStruct(values);
catch err
    try
        distcomp.configserializer.deleteConfig(obj.ActualName);
    catch err2 %#ok<NASGU>
        % Failed to delete.
    end
    error('distcomp:configuration:importFailed', ...
          ['Could not import configuration from the file %s\n', ...
           'due to the following error:\n%s'], filename, err.message);
end

obj.save();
name = obj.Name;
