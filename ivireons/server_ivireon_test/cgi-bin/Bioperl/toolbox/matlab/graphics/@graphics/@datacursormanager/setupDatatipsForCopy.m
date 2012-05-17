function setupDatatipsForCopy(hThis)
% Serializes the information located in the data cursors associated with
% the mode and stores them in application data of each target. If this is
% going to be done on a figure that will be serialized, use the
% serializeDatatips method.

%   Copyright 2008 The MathWorks, Inc.

% Get a handle to the data tips:
hDatatips = hThis.DataCursors;

if isempty(hDatatips)
    return;
end

% For each data tip, create a structure containing the necessary
% information for reconstruction.
dataStruct = struct('DataIndex','','Position','',...
    'InterpolationFactor','','TargetPoint','');

for i=1:numel(hDatatips)
    currCursor = hDatatips(i).DataCursorHandle;
    hTarget = get(currCursor,'Target');
    targetStruct = dataStruct(2:end);
    if isappdata(double(hTarget),'DatatipInformation')
        targetStruct = getappdata(double(hTarget),'DatatipInformation');
    end
    fNames = fieldnames(dataStruct);
    for j = 1:numel(fNames)
        name = fNames{j};
        dataStruct.(name) = get(currCursor,name);
    end
    targetStruct(end+1) = dataStruct; %#ok<AGROW>
    setappdata(double(hTarget),'DatatipInformation',targetStruct);
end