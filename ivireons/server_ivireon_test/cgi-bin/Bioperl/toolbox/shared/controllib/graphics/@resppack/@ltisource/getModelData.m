function D = getModelData(this,idxModel)
% Extracts low-level data representation of LTI model

%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision $ $Date: 2010/03/26 17:49:44 $
D = getPrivateData(this.Model);
if nargin>1
   D = D(idxModel);
end