function deserializeDatatips(hThis)
% Deserialized the information located in the application data of the
% figure and creates datatips corresponding to the information found there.

%   Copyright 2007 The MathWorks, Inc.

hFig = hThis.Figure;
if ~isappdata(hFig,'DatatipInformation')
    return;
end

% Get the update function of the mode
modeUpdateFcn = getappdata(hFig,'DatatipUpdateFcn');
if ~isempty(modeUpdateFcn)
    if iscell(modeUpdateFcn)
        hFun = modeUpdateFcn{1};
    else
        hFun = modeUpdateFcn;
    end
    % The update function can either be a string or a function handle at
    % this point, if it is a function handle, make sure we can find the
    % file.
    if isa(hFun,'function_handle')
        funInfo = functions(hFun);
        funFile = funInfo.file;
        funName = funInfo.function;
        if isempty(funFile) || (~isempty(funFile) && ~exist(funFile,'file'))
            warning('MATLAB:graphics:deserializeDatatips',...
                'The previously accessible function "%s" is now inaccessible.\n The default data cursor update function will be used instead.',funName);
        else
            hThis.UpdateFcn = modeUpdateFcn;
        end
    else
        hThis.UpdateFcn = modeUpdateFcn;
    end
end
rmappdata(hFig,'DatatipUpdateFcn');

dataStruct = getappdata(hFig,'DatatipInformation');
rmappdata(hFig,'DatatipInformation');

for i = 1:numel(dataStruct);
    hThis.createDatatip(dataStruct(i).Target,dataStruct(i));
end