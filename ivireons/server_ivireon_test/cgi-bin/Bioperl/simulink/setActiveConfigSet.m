function setActiveConfigSet(mdl, name)
% SETACTIVECONFIGSET Select an existing configuration set to be the active 
%    configuration set of a Simulink model.
%    
%    setActiveConfigSet('model', 'name') selects an existing configuration
%    set of the model that matches the given name and make it the active
%    configuration set.

% Copyright 2002-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $
    
  hMdl = get_param(mdl, 'Object');
  hMdl.setActiveConfigSet(name);
% LocalWords:  setActiveConfigSet mdl Simulink MathWorks hMdl param
