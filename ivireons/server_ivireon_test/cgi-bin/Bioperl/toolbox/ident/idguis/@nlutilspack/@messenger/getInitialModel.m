function m = getInitialModel(h,Type,ModelName)
% return idnlmodel of type Type and with name ModelName.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/10/02 18:50:49 $

m = [];
allModels = idactmod(Type);
for k = 1:length(allModels)
    if strcmp(allModels{k}.Name,ModelName)
        m = allModels{k};
        break;
    end
end
