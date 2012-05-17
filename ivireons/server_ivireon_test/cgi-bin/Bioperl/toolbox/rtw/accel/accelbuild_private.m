function accelbuild_private(modelName,okToPushNags)
%ACCELBUILD_PRIVATE Private Acclerator build function
%
%   This is a back-end function for use with the Real-Time Workshop
%   when creating an Accelerator MEX-file for use with the Simulink
%   Accelerator. It is not intended to be directly used or modified.
%  
%   See also ACCELBUILD.

%
%       Copyright 1994-2008 The MathWorks, Inc.
%       $Revision: 1.7.2.17 $


  % Build the mex file
  LocalAccelbuildprivate(modelName,okToPushNags);

%endfunction accelbuild_private


% Function: LocalAccelbuild_private ==========================================
% Abstract:
%	Build a mex file (model_acc.mex) corresponding to a Simulink model
%       for the Simulink accelerator.
%
%       Switches RTW parameters for Accelerator builds and then uses
%       make_rtw as is.  Also, returns success or failure so that
%       Simulink can take appropriate steps.
%
function LocalAccelbuildprivate(modelName,okToPushNags)

  hModel = get_param(modelName,'handle');

  accelSystemTargetFile = get_param(hModel,'AccelSystemTargetFile');
  accelTemplateMakeFile = get_param(hModel,'AccelTemplateMakeFile');
  accelMakeCommand      = get_param(hModel,'AccelMakeCommand');
  accelVerboseBuild     = get_param(hModel,'AccelVerboseBuild');
  
  activeConfigSet       = getActiveConfigSet(hModel);
  MangleLength          = get_param(activeConfigSet, 'MangleLength');
  switchTarget(activeConfigSet, accelSystemTargetFile, []);
  set_param(hModel,'RTWTemplateMakeFile',  accelTemplateMakeFile);
  set_param(hModel,'RTWMakeCommand',       accelMakeCommand);
  set_param(hModel,'RTWBuildArgs',         '');
  set_param(hModel,'RTWGenerateCodeOnly',  'off');
  set_param(hModel,'RTWVerbose',accelVerboseBuild);
  set_param(activeConfigSet, 'MangleLength',    MangleLength);

  % Register the simulation target tfl
  tfl = get_param(hModel, 'SimTargetFcnLibHandle');
  set_param(hModel, 'TargetFcnLibHandle', tfl);
  
  % Set the target language to C++ if it is 'C++ (Encapsulated)'
  if strcmp(get_param(hModel,'TargetLang'), 'C++ (Encapsulated)')
      set_param(hModel, 'TargetLang', 'C++'); 
  end

  rtwbuild(modelName,'OkayToPushNags',okToPushNags);

%endfunction LocalAccelbuildprivate


