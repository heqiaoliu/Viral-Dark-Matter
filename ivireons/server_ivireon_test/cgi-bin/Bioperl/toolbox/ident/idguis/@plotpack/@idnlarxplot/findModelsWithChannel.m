function [models,Loc] = findModelsWithChannel(this,yName)
% Find all models that contain an output with name yName.
% Loc: Location index of the channel name in each model that contains
% yName.
% Note: models are not idnlarx models, but the wrapper nlarxdata objects

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:47 $

models = handle([]);
Loc = [];

for k = 1:length(this.ModelData)
    i2 = find(strcmp(yName,this.ModelData(k).Model.OutputName));
    if ~isempty(i2)
        models(end+1) = this.ModelData(k);
        Loc(end+1,:) = i2;
    end
end
