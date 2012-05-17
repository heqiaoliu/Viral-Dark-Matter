function h = detachConfigSet(mdl, name)
% DETACHCONFIGSET Detach a configuration set from a Simulink model.
%    
%    detachConfigSet('model', 'name') detaches a configuration set with matching
%    name from the model.  It returns the handle of the matching configuration 
%    set object.

% Copyright 2002-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $
    
  hMdl = get_param(mdl, 'Object');
  h = hMdl.detachConfigSet(name);

% LocalWords:  detachConfigSet Simulink
