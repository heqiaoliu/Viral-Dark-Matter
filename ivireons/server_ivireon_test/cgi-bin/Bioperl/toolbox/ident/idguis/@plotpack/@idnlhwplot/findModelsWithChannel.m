function [models,Loc] = findModelsWithChannel(this,uName,yName)
% find all models that contain an input with name uName and an output with
% name yName.
% if uName is empty, the search is made for output names only (and
% vice-versa). Both uName and yName cannot be empty.
% Loc: Location index of the channel name(s) in each model that contains
% those name(s).

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:51:02 $

models = handle([]);
Loc = [];

for k = 1:length(this.ModelData)
    if ~isempty(uName) && ~isempty(yName)
        i1 = find(strcmp(uName,this.ModelData(k).Model.InputName));
        i2 = find(strcmp(yName,this.ModelData(k).Model.OutputName));
        if ~isempty(i1) && ~isempty(i2)
            models(end+1) = this.ModelData(k);
            Loc(end+1,:) = [i1 i2];
        end
    elseif ~isempty(yName)
        i2 = find(strcmp(yName,this.ModelData(k).Model.OutputName));
        if ~isempty(i2)
            models(end+1) = this.ModelData(k);
            Loc(end+1,:) = i2;
        end
    elseif ~isempty(uName)
        i1 = find(strcmp(uName,this.ModelData(k).Model.InputName));
        if ~isempty(i1)
            models(end+1) = this.ModelData(k);
            Loc(end+1,:) = i1;
        end
    else
        ctrlMsgUtils.error('Ident:idguis:findModelsWithChannels1')
    end
end
