function activeConfig = setNonSimWarningOff(this,models)
% SETNONSIMWARNINGOFF  Set the non simulation warnings off and return the
% old configuration set.
%
 
% Author(s): John W. Glass 01-Jun-2006
%   Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2.14.1 $ $Date: 2010/07/26 15:39:00 $

if ~iscell(models)
    models = {models};
end

for ct = numel(models):-1:1
    activeConfig = getActiveConfigSet(models{ct});
    if isa(activeConfig, 'Simulink.ConfigSetRef')
        referencedConfig = activeConfig.getRefConfigSet;
        develConfig = referencedConfig.copy;
    else
        develConfig = activeConfig.copy;
    end
    
    develConfig.Components(4).AlgebraicLoopMsg = 'none';
    develConfig.Components(4).SolverPrmCheckMsg = 'none';
    develConfig.Components(4).UnconnectedInputMsg = 'none';
    develConfig.Components(4).UnconnectedOutputMsg = 'none';
    develConfig.Components(4).UnconnectedLineMsg = 'none';
    attachConfigSet(models{ct}, develConfig, true);
    setActiveConfigSet(models{ct}, develConfig.Name);
end
