function ModelType = getCurrentModelTypeID(this)
% Return current model type ('idnlarx' or 'idnlhw') based on the selected
% structure index, which is stored in Data.StructureIndex

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/07/03 20:43:13 $

if (this.Data.StructureIndex==1)
    ModelType = 'idnlarx';
else
    ModelType = 'idnlhw';
end