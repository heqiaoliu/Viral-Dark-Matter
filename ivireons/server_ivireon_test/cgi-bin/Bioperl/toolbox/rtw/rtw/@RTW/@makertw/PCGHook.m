function PCGHook(h)
%   PCGHook method gets called inside make_rtw method.

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2010/05/20 02:54:05 $

%
% This is the Post code generation point of image building.
%

% Define function workspace variables. Note: these variables names are
% documented to be present and must not be changed.
modelName = h.ModelName; % string
buildInfo = h.BuildInfo;

% Get the command string specified in the model
pcgCommand = get_param(modelName, 'PostCodeGenCommand');

if ~isempty(pcgCommand)
  if strcmp(get_param(modelName, 'RTWVerbose'),'on')
    disp('### Evaluating PostCodeGenCommand specified in the model');
  end
  try
      % If the make hook cd's to a different dir, we want to force it
      % back to the current dir.
      cur_pwd = pwd;

      eval(pcgCommand);
  catch exc
      % the original error message is formatted with various HTML
      % formatting and possible drive letter specification.  clean it
      % up before including it
      errMsg = rtwprivate('escapeOriginalMessage',exc);
      cd(cur_pwd);
      errID = 'RTW:buildProcess:invalidPostCodeGenCommand';
      errMsg = DAStudio.message(errID, 'PostCodeGenCommand', errMsg);
      newExc = MException(errID, errMsg);
      newExc = newExc.addCause(exc);
      throw(newExc);
  end
  
  % For now, if the make hook cd'd, just issue a warning and continue
  if ~strcmp(cur_pwd,pwd)
      DAStudio.warning('RTW:makertw:changeDirNotAllowed',...
                       'PostCodeGen command', pwd, cur_pwd);
      cd(cur_pwd);
  end

end

% Dispatch any build hooks attached to the model
isSimBuild = slprivate(...
    'isSimulationBuild',...
    modelName,...
    h.MdlRefBuildArgs.ModelReferenceTargetType);
if ~isSimBuild
    hookArgs={'after_code_generation',modelName, '','',buildInfo};
    rtw.pil.BuildHook.dispatch(hookArgs{:});
end

