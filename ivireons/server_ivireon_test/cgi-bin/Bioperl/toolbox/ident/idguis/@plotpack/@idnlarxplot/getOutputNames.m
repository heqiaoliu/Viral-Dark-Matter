function ynv = getOutputNames(this)
% get a list of output names

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:53 $

ynv = {};
for k = 1:length(this.ModelData)
    if ~this.ModelData(k).isActive
        % skip inactive models
        continue;
    end
    modelk = this.ModelData(k).Model;
    yn = modelk.yname;
    for  i = 1:length(yn)
        if ~any(strcmp(ynv,yn{i}))
            ynv = [ynv;yn{i}];
        end
    end
end
