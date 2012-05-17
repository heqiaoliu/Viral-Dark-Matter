function serializeDatatips(hThis)
% Serializes the information located in the data cursors associated with
% the mode and stores them in application data of the figure:

%   Copyright 2007 The MathWorks, Inc.

% Get a handle to the data tips:
hDatatips = hThis.DataCursors;

if isempty(hDatatips)
    return;
end

% For each data tip, create a structure containing the necessary
% information for reconstruction.
dataStruct = struct('Target','','DataIndex','','Position','',...
    'InterpolationFactor','','TargetPoint','');
dataStruct = repmat(dataStruct,size(hDatatips));

for i=1:numel(hDatatips)
    currCursor = hDatatips(i).DataCursorHandle;
    fNames = fieldnames(dataStruct);
    for j = 1:numel(fNames)
        name = fNames{j};
        dataStruct(i).(name) = get(currCursor,name);
    end
end

setappdata(hThis.Figure,'DatatipInformation',dataStruct);

% Store a handle to the update function of the mode as well.
modeUpdateFcn = hThis.UpdateFcn;
setappdata(hThis.Figure,'DatatipUpdateFcn',modeUpdateFcn);