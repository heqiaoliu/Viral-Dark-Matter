function retVal = getMdlrefNumVariants(mdlBlk)
%GETMDLREFNUMVARIANTS  Return how many variants a model block has

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

try
    if Simulink.getMdlrefIsVariant(mdlBlk)
        retVal = length(get_param(mdlBlk, 'Variants'));
    else
        retVal = 0;
    end

catch exception
    switch exception.identifier
      case {'Simulink:Commands:InvSimulinkObjHandle','Simulink:Commands:ParamUnknown'}
        DAStudio.error('Simulink:tools:GetMdlRefVariantInfoWrongBlockType', mfilename);
      otherwise
        rethrow(exception);
    end
end

