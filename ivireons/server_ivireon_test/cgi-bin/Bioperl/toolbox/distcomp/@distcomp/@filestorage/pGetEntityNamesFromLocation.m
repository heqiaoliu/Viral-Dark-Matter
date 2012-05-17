function [names, values] = pGetEntityNamesFromLocation(obj, path, type)
; %#ok Undocumented
%pGetEntityNamesFromLocation gets the valid names from the storgae location

%  Copyright 2004-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/03/31 17:07:27 $


ext = obj.Extensions{1};
% Find all the objects that are of the current type
files = dir([path filesep '*' ext]);
% Remove all directories as they aren't relevant (They are children of the
% objects at this level, or . / ..)
files([files.isdir]) = [];
% Get just the names
names = {files.name};
% Remove those that don't start with the appropriate string
names = names(strmatch(type, names));
% Remove the leading type and the trailing extension
startIndex = numel(type) + 1;
endIndex   = numel(ext);
values     = zeros(size(names));
for i = 1:numel(names)
    % Strip the extension off the name
    names{i} = names{i}(1:end-endIndex);
    % Convert the name after type to a double using sscanf
    [thisValue, count] = sscanf(names{i}(startIndex:end), '%d');
    % How many items were converted? Not 1 is an error
    if count ~= 1
        thisValue = NaN;
    end
    values(i) = thisValue;
end
% Note that we have put NaN in for non-numeric conversions 
% Remove those that didn't convert to a double
names(isnan(values)) = [];
values(isnan(values)) = [];
