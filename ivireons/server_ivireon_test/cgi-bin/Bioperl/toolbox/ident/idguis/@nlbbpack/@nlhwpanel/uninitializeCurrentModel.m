function uninitializeCurrentModel(this)
%Reset the parameter values and estimation status of idnlhw model

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:13:09 $

model = nlutilspack.uninitializeModel(this.NlhwModel);
this.updateModel(model);
