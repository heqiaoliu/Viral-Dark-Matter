function setLatestEstimModelName(this,modelName,Type)
% set name of latest estimated model in objects as well as estimation panel

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2008/10/31 06:13:02 $

visibleType = this.ModelTypePanel.getCurrentModelTypeID; %char(this.ModelTypePanel.jMainPanel.getCurrentModelTypeID);
if nargin<3
    Type = visibleType;
    visibleTypeModified = true;
else
    visibleTypeModified = strcmpi(Type,visibleType);
end

% update object
this.ModelTypePanel.getPanelForType(Type).LatestEstimModelName = modelName;

if visibleTypeModified
    % update estimaiton panel's display
    % also, disable checkboxes if modelName is ''.
    this.EstimationPanel.jMainPanel.setLatestEstimModel(modelName); %event-thread method
end
