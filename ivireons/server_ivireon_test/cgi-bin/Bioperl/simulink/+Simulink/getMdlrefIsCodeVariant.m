function retVal = getMdlrefIsCodeVariant(mdlBlk)
%GETMDLREFISCODEVARIANT  Return whether the model reference block is 
% a code variant model

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

try
    retVal = strcmp(get_param(mdlBlk,'HasCodeVariants'), 'on') == 1;

catch exception
    switch exception.identifier
      case {'Simulink:Commands:InvSimulinkObjHandle','Simulink:Commands:ParamUnknown'}
        DAStudio.error('Simulink:tools:GetMdlRefVariantInfoWrongBlockType', mfilename);
      otherwise
        rethrow(exception);
    end
end
    
