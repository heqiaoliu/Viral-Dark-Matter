function active = getAllEnabledInSection(obj, sectionName)
; %#ok Undocumented
%Returns the enabled properties and their values in the specified section.

%   Copyright 2007 The MathWorks, Inc.

% Verify that sectionName is a string.
if ~(ischar(sectionName) && length(sectionName) == size(sectionName, 2) ...
        && ~isempty(sectionName))
    error('distcomp:configuration:InvalidSectionName', ...
          'Configuration section name must be a non-empty string.');
end

try
    sec = obj.(sectionName);
catch
    error('distcomp:configuration:InvalidSection', ...
          'Invalid configuration section ''%s''.', ...
          sectionName);
end

active = sec.getEnabledStruct();
