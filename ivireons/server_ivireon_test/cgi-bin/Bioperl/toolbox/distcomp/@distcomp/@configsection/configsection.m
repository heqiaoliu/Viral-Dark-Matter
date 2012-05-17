function obj = configsection(sectionName, names, datatypes, isWritable)
; %#ok Undocumented
%   Create a config section using the property names, their types and writable
%   status.

%   Copyright 2007 The MathWorks, Inc.

obj = distcomp.configsection;
obj.SectionName = sectionName;

% Make sure the inputs are of the correct types.
if ~iscellstr(names)
    error('distcomp:configsection:InvalidInput', ...
          'Property names must be specified as a cell array of strings.');
end

if ~iscellstr(datatypes)
    error('distcomp:configsection:InvalidInput', ...
          'Property data types must be specified as a cell array of strings.');
end

if ~islogical(isWritable)
    error('distcomp:configsection:InvalidInput', ...
          'Property writable status must be specified as a vector of logicals.');
end

% Make sure the vectors are all of the same length.
if ~(length(names) == length(datatypes) && length(names) == length(isWritable))
    error('distcomp:configsection:InvalidInput', ...
          ['Property names, data types and writable status must be ', ...
          'of equal length.']);
end
% Make sure that the names are unique.    
if length(names) ~= length(unique(names))
    error('distcomp:configsection:InvalidPropertyNames', ...
          'Property names must be unique.');
end

obj.Names = names;
obj.Types = datatypes;
obj.IsPropEnabled = false(size(names));
% All non-writable fields are enabled by default.  Otherwise, the user will
% never see them!
obj.IsPropEnabled(~isWritable) = true;

obj.IsPropWritable = isWritable;
obj.PropValue = cell(size(names));

for i = 1:length(names)
    obj.PropValue{i} = distcomp.typechecker.getDefaultValue(obj.Types{i});
end
