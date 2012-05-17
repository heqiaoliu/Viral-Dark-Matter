function new_configset = attachConfigSetCopy(model, cs, allowRename)
% ATTACHCONFIGSETCOPY Copy a configuration set and attach it to a model.
% 
%    NEWCONFIGSET = ATTACHCONFIGSETCOPY(MODEL, CONFIGSET) creates a copy 
%    of CONFIGSET and attaches that copy to MODEL.  The newly created
%    configuration set is returned.
%
%    CONFIGSET must have a name that is different from the name of any
%    other configuration sets attached to MODEL.
%
%    NEWCONFIGSET = ATTACHCONFIGSETCOPY(MODEL, CONFIGSET, ALLOWRENAME)
%    creates a copy of CONFIGSET and attaches that copy to MODEL.  
%    The newly created configuration set is returned.
%
%    If ALLOWRENAME is set to true and there is a naming conflict,
%    Simulink will choose a new name for NEWCONFIGSET when it is attached 
%    to MODEL.
%
%    If ALLOWRENAME is set to false, CONFIGSET must have a name that is 
%    different from the name of any other configuration sets attached 
%    to MODEL.
%
%    In the following examples, assume myModelA.mdl and myModelB.mdl exist.
%
%    Example
%       modelA = load_model('myModelA');
%       modelB = load_model('myModelB');
%       activeConfigA = getActiveConfigSet(modelA);
%       activeConfigA.Name = 'activeConfigA';
%       newConfig = attachConfigSetCopy(modelB, activeConfigA);
%
%    Example
%       model = load_model('myModelA');
%       activeConfig = getActiveConfigSet(model);
%       newConfig = attachConfigSetCopy(model, activeConfig, true);
%    
%    See also ATTACHCONFIGSET, GETCONFIGSET, GETCONFIGSETS, 
%    GETACTIVECONFIGSET, DETACHCONFIGSET.

% Copyright 2002-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

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
          DAStudio.error('Simulink:utility:slAttachConfigSetCopyInvalidModeArg');
      end
  end

  hMdl = get_param(model, 'Object');
  new_configset = hMdl.attachConfigSetCopy(cs, mode);
