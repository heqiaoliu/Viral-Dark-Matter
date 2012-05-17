function [srcCS, origCS] = mdl_get_configset(modelH)

%   Copyright 2009 The MathWorks, Inc.

    modelObj = get_param(modelH, 'Object');
    origCS = modelObj.getActiveConfigSet();
    srcCS = origCS;
    while (srcCS.isa('Simulink.ConfigSetRef'))
      srcCS = srcCS.getRefConfigSet();
    end
end