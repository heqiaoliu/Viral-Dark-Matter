function D = getUncertainModelData(this,idxModel)
% Extracts low-level data representation of LTI model

%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision $ $Date: 2010/03/26 17:49:45 $
% D = this.UncertainModel;

if isempty(this.UncertainModel)
    D = this.getModelData;
else
    
    D = getPrivateData(this.UncertainModel);
    if nargin>1
        D = D(idxModel);
    end
end