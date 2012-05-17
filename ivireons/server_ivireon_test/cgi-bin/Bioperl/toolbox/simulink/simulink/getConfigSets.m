function ret = getConfigSets(mdl)
%GETCONFIGSETS Return the names of all configuration set objects that are 
%   attached to a Simulink model.
%
%   getConfigSets('model') returns a cell array of names of all configuration
%   set objects that are attached to the Simulink model.

% Copyright 2003-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $
  
  hMdl = get_param(mdl, 'Object');
  ret = hMdl.getConfigSets;
  
% LocalWords:  getConfigSets mdl Simulink MathWorks hMdl param
