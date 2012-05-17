function loadActiveConfigSet(model, filename)
% loadActiveConfigSet -- load active configuration set to model
% 
% Syntax:
% Simulink.BlockDiagram.loadActiveConfigSet(model, filename)
%
% Input:
%    model    -- Name or handle of a model
%    filename -- The name of the MATLAB- or MAT-file to load. If no extension, defaults to .m.
%
% See Also:
%   attachConfigSet, setActiveConfigSet
% 

% Copyright 2003-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $
  
  if nargin < 2
    DAStudio.error('Simulink:ConfigSet:MissingInpArgs');
  end

  % validate model
  if ishandle(model)
      sysFound = ~isempty(find_system('type', 'block_diagram', 'handle', model));
      model_name = num2str(model);
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

  if strcmp(model_name, name)
      DAStudio.error('Simulink:ConfigSet:MdlCSNameConflict', name);
  end
  
  % validate file extension
  if isempty(ext)
      % if extension is not provided, default is MATLAB function
      % MAT file will be used if MATLAB function is not existed
      if exist([filename, '.m'], 'file')
          ext = '.m';
      else
          DAStudio.error('Simulink:ConfigSet:fileNotExisted', filename);
      end
  elseif strcmp(ext, '.m')
      ext = '.m';
  elseif strcmp(ext, '.mat')
      textFormat = false;
  else
      DAStudio.error('Simulink:ConfigSet:badFileExtension');
  end

  filename = fullfile(pathstr, [name ext]);
  % error out if the specified file is not existed
  if ~exist(filename, 'file')
      DAStudio.error('Simulink:ConfigSet:fileNotExisted', filename);
  end
  
  active_CS_model = getActiveConfigSet(model);

  % load configset depending on the chosen format  
  if textFormat
      cls = internal.matlab.codetools.reports.matlabType.findType(filename);
      % error out if it's not MATLAB function
      if ~strcmp(class(cls), 'internal.matlab.codetools.reports.matlabType.Function')
          DAStudio.error('Simulink:ConfigSet:notMATLABFunction', filename);
      end
      
      if ~isempty(pathstr)
        cur_Dir = pwd;
        cd(pathstr);
      end
      
      % error out if it's not VALID MATLAB function
      try
          cs_tmp = eval(name);
      catch ME
          DAStudio.error('Simulink:ConfigSet:badMATLABFunctionNoConfigSet', filename);
      end

      % warning given if the MATLAB function returns multiple objects
      if nargout(name) > 1
          DAStudio.error('Simulink:ConfigSet:badMATLABFunctionMultiConfigSet', filename);
      end
      
      % error out if the MATLAB function doesn't return a ConfigSet object
      if ~isa(cs_tmp, 'Simulink.ConfigSet')
          DAStudio.error('Simulink:ConfigSet:badMATLABFunctionNoConfigSet', filename);
      end
      
      if ~isempty(pathstr)
          cd(cur_Dir);
      end
  else
      % load MAT file
      objInMAT = load(filename);

      % error out if there are multiple ConfigSet objects in the MAT file
      csIdx = 0;
      f = fields(objInMAT);
      for i=1:length(f)
          if strcmp(class(objInMAT.(f{i})), 'Simulink.ConfigSet') 
              if ~csIdx
                  csIdx = i;
              else
                  DAStudio.error('Simulink:ConfigSet:multipleCSinMATFile');
              end
          end
      end

      % warning given if there are other types of objects (other than ConfigSet) in the  MAT file
      if length(f) > 1
          DAStudio.warning('Simulink:ConfigSet:otherObjsinMATFile');
      end
  
      cs_tmp = objInMAT.(f{csIdx});
  end

  origName = cs_tmp.name;
  allCS = getConfigSets(model);

  % detach all configuration (of the model) that has the same name of the load ConfigSet object
  for i=1:length(allCS)
      if strcmp(allCS(i), origName) && ~strcmp(allCS(i),active_CS_model.Name)
          detachConfigSet(model, allCS{i});
          DAStudio.warning('Simulink:ConfigSet:csNameConflict', origName);
          break;
      end
  end
  
  % set the loaded ConfigSet object as the active configuration of the model
  attachConfigSet(model, cs_tmp, 1);
  setActiveConfigSet(model, cs_tmp.name);
  
  % warning given if the original active configuration is a ConfigSet reference
  if isa(active_CS_model, 'Simulink.ConfigSetRef')
      DAStudio.warning('Simulink:ConfigSet:warningToReplaceConfigSetRef', model_name);
  end
  
  detachConfigSet(model, active_CS_model.Name);
  cs_tmp.name = origName;  
end
%EOF
