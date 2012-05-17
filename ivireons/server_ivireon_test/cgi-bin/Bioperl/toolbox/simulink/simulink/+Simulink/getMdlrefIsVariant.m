function retVal = getMdlrefIsVariant(mdlBlk)
%GETMDLREFISVARIANT  Return whether the model reference block is 
% a variant model

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

try
    retVal = strcmpi(get_param(mdlBlk, 'HasVariants'), 'on') == 1;

catch exception
    switch exception.identifier
      case {'Simulink:Commands:InvSimulinkObjHandle','Simulink:Commands:ParamUnknown'}
        DAStudio.error('Simulink:tools:GetMdlRefVariantInfoWrongBlockType', mfilename);
      otherwise
        rethrow(exception);
    end
end
