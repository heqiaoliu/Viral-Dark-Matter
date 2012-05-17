function attachConfigSet(model, cs, allowRename)
% ATTACHCONFIGSET Attach a standalone configuration set to a model.
% 
%    ATTACHCONFIGSET(MODEL, CONFIGSET) attaches a standalone
%    configuration set (i.e. a configuration that is not attached to 
%    any model) to MODEL.
%
%    CONFIGSET must have a name that is different from the name of any 
%    other configuration sets attached to MODEL.
%
%    ATTACHCONFIGSET(MODEL, CONFIGSET, ALLOWRENAME) attaches a standalone
%    configuration set (i.e. a configuration that is not attached to 
%    any model) to MODEL.
%
%    If ALLOWRENAME is set to true and there is a naming conflict,
%    Simulink will choose a new name for CONFIGSET when it is attached 
%    to MODEL.
%
%    If ALLOWRENAME is set to false, CONFIGSET must have a name that is 
%    different from the name of any other configuration sets attached 
%    to MODEL.
%
%    In the following examples, assume myModel.mdl exists.
%
%    Example (Assume myModel.mdl exists)
%       model = load_system('myModel');
%       activeConfig = getActiveConfigSet(model);
%       newConfig = activeConfig.copy;
%       newConfig.Name = 'newConfig';
%       attachConfigSet(model, newConfig);
%
%    Example (Assume myModel.mdl exists)
%       model = load_system('myModel');
%       activeConfig = getActiveConfigSet(model);
%       newConfig = activeConfig.copy;
%       attachConfigSet(model, newConfig, true);
%    
%    See also ATTACHCONFIGSETCOPY, GETCONFIGSET, GETCONFIGSETS, 
%    GETACTIVECONFIGSET, DETACHCONFIGSET.

% Copyright 2002-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $

  error(nargchk(2, 3, nargin, 'struct'));
  
  %By default, Simulink will not automatically rename the configuration set.
  mode = false;
  
  if(nargin == 3)
      if(isequal(allowRename, 0))
          mode = false;
      elseif(isequal(allowRename, 1))
          %Simulink rename the configuration set if there is a conflict.
          mode = true;
      else
          DAStudio.error('Simulink:utility:slAttachConfigSetInvalidModeArg');
      end
  end

  hMdl = get_param(model, 'Object');
  hMdl.attachConfigSet(cs, mode);
