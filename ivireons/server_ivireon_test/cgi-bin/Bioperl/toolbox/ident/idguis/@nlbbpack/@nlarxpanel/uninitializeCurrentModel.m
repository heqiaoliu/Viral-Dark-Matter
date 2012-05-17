function uninitializeCurrentModel(this)
%Reset the parameter values and estimation status of idnlarx model

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:12:51 $

model = nlutilspack.uninitializeModel(this.NlarxModel);
this.updateModel(model);
