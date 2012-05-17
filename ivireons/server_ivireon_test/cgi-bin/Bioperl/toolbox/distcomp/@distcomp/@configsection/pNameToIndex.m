function index = pNameToIndex(obj, name)
; %#ok Undocumented
%Returns the index that matches the property name.

if ~(ischar(name) && length(name) == size(name, 2))
    error('distcomp:configsection:InvalidPropertyName', ...
          'Configuration properties must be strings.');
end

index = find(strcmp(obj.Names, name));
if isempty(index)
    error('distcomp:configsection:InvalidPropertyName', ...
          ['There is no property named ''%s'' in ', ...
           'the configuration section ''%s''.'], name, obj.SectionName);
end

% The constructor of this object ensures uniqueness, so length(index) must be 1.
