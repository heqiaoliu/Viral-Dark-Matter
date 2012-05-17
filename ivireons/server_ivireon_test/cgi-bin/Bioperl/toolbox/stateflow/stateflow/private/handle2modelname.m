function modelName = handle2modelname(blockHandle)

%   Copyright 2010 The MathWorks, Inc.

   mdlHandle = bdroot(blockHandle);
   modelName = get_param(mdlHandle, 'name');
end