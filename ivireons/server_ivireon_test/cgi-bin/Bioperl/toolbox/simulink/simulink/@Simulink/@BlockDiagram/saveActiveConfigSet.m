function saveActiveConfigSet(model, filename)
% saveActiveConfigSet -- save active configuration set of model
% 
% Syntax:
% Simulink.BlockDiagram.saveActiveConfigSet(model, filename)
%
% Input:
%    model    -- Name or handle of a model
%    filename -- The name of the MATLAB- or MAT-file to save. If no extension, defaults to .m.
%
% See Also:
%    Simulink.ConfigSet.saveAs
% 

% Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $
  
  if nargin < 2
    DAStudio.error('Simulink:dialog:MissingInpArgs');
  end

  % validate model
  if ishandle(model)
      sysFound = ~isempty(find_system('type', 'block_diagram', 'handle', model));
      model_name = get_param(model,'name');
  elseif ischar(model)
      sysFound = ~isempty(find_system('type', 'block_diagram', 'name', model));
      model_name = model;
  else
      DAStudio.error('Simulink:ConfigSet:FirstInpArgMustBeValidModel');
  end

  % error out if model is not a block diagram
  if ~sysFound
    if ishandle(model)
      DAStudio.error('Simulink:ConfigSet:NoModelWithHandle', model_name);
    elseif ischar(model)
      DAStudio.error('Simulink:ConfigSet:ModelNotFound', model_name);
    end
  end

  textFormat = true;
  [pathstr, name, ext] = fileparts(filename);

  % validate file extension
  if isempty(ext) || strcmp(ext, '.m')
      ext = '.m';      
  elseif strcmp(ext, '.mat')
      textFormat = false;
  else
      DAStudio.error('Simulink:ConfigSet:badFileExtension');
  end      

  filename = fullfile(pathstr, [name ext]);
  cs = getActiveConfigSet(model);

  % only configset is to be saved
  if ~isa(cs, 'Simulink.ConfigSet')
      DAStudio.error('Simulink:ConfigSet:saveAsOnlyConfigSet', model_name);
  end

  % save configset depending on the chosen format
  if textFormat
      cs.saveAs(filename);            % ConfigSet saveAs method
  else
      save(filename, 'cs');
  end  
end
%EOF
