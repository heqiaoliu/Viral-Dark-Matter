function h = getConfigSet(mdl, name)
% GETCONFIGSET Return a handle to a configuration set object in a Simulink
%    model.
%
%    getConfigSet('model', 'name') returns a handle to the configuration set
%    object of the matching name in a Simulink model.

% Copyright 2002-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $
    
  hMdl = get_param(mdl, 'Object');
  h = hMdl.getConfigSet(name);
  
% LocalWords:  getConfigSet mdl Simulink MathWorks hMdl param
