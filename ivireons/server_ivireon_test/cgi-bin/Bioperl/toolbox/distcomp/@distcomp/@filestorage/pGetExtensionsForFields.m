function [extensions, fileFormat] = pGetExtensionsForFields(obj, type, names);
; %#ok Undocumented
%pGetExtensionsForFields 
%
%  EXTENSIONS = PGETEXTENSIONSFORFIELDS(STORAGE, NAMES)

% Copyright 2004-2006 The MathWorks, Inc.


transform = obj.FieldToExtensionTransform;
% Is type defined in the FieldToExtensionTransform
typeIndex = find(strcmp(type, {transform.Type}));
% Did we find it at all
if isempty(typeIndex)
    error('distcomp:filestorage:InvalidType', 'Attempt to store a type called ''%s'' which does not exist', type);
end
% Extract the lists of names and extension index
validNames = transform(typeIndex).FieldName;
validExt   = transform(typeIndex).ExtensionIndex;
% Try and find the names in the validNames
[found, extIndex] = ismember(names, validNames);
% Convert from an index into validNames into the value in validExt
extIndex(found) = validExt(extIndex(found));
% Default if not found is to use extension 1 - should be .common.mat?
extIndex(~found) = 1;
% Return the cell array of extensions to the user
extensions = obj.Extensions(extIndex);
% Also return if this extension is a mat file or not
fileFormat = obj.FileFormat(extIndex);
% Possibly want to return a single char extension
if ischar(names)
    extensions = extensions{1};
    fileFormat = fileFormat{1};
end
