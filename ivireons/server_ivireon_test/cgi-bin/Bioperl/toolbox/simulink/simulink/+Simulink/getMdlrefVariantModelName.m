function retVal = getMdlrefVariantModelName(mdlBlk, i)
%GETMDLREFVARIANTMODELNAME  Return the model name of the ith variant of a 
% model block

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

try
    if Simulink.getMdlrefIsVariant(mdlBlk)
        variants = get_param(mdlBlk, 'Variants');
        retVal = variants(i).ModelName;
    else
        retVal = [];
    end
catch exception
    switch exception.identifier
      case {'Simulink:Commands:InvSimulinkObjHandle','Simulink:Commands:ParamUnknown'}
        DAStudio.error('Simulink:tools:GetMdlRefVariantInfoWrongBlockType', mfilename);
      case {'MATLAB:badsubscript'}
        if i <= 0
            DAStudio.error('Simulink:tools:GetMdlRefVariantInfoNonPositiveVariantIndex', mfilename);
        else
            numVariants = Simulink.getMdlrefNumVariants(mdlBlk);
            DAStudio.error('Simulink:tools:GetMdlRefVariantInfoTooLargeVariantIndex', getBlockPath(mdlBlk), numVariants, mfilename, numVariants);
        end
                    
      otherwise
        rethrow(exception);
    end
end

