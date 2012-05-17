function dataHandlerClass = getDataHandlerClass(this, hVisual)
%GETDATAHANDLERCLASS Get the dataHandlerClass.
%   OUT = GETDATAHANDLERCLASS(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/03/17 22:43:11 $

hReg = this.Register;

if nargin < 2
    hVisual = this.Application.Visual;
end

if isempty(hVisual)
    visName = 'Video'; %default
else
    visName = hVisual.Register.Name;
end

% Convert the visual name to a valid field name.
visName = genvarname(visName);

% Get the DataHandlers application data.
dataHandlers = getAppData(hReg, 'DataHandlers');
if isfield(dataHandlers, visName)
    
    % Get the data handler from the structure for the specified visual.
    dataHandlerClass = dataHandlers.(visName);
    
    % We have code in addDataHandler which allows for multiple handlers per
    % source/visual pair.  For now we only support one, so just return the
    % first registered DataHandler.
    if iscell(dataHandlerClass)
        dataHandlerClass = dataHandlerClass{1};
    end
else
    
    % If there is no data handler registered, return the default for this source.
    dataHandlerClass = getDefaultHandlerClass(this);
end

% [EOF]
