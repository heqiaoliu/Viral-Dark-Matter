function asap2_make_rtw_hook(varargin)
% ASAP2_MAKE_RTW_HOOK - ASAP2 target-specific hook file for the build process (make_rtw).

%   Copyright 1994-2009 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $ $Date: 2009/12/28 04:28:32 $

persistent MODEL_SETTINGS

Action    = varargin{1};
modelName = varargin{2};

switch Action
case 'entry'
  % Check property settings for generation of ASAP2 file.
  % Record old settings if being changed for duration of ASAP2 generation process.
  if strcmp(get_param(modelName, 'RTWInlineParameters'), 'off')
    MODEL_SETTINGS.RTWInlineParameters = 'off';
    set_param(modelName, 'RTWInlineParameters', 'on');
    DAStudio.warning('RTW:asap2:RTWInlineParamOn');
  end
  
  if strcmp(get_param(modelName, 'RTWGenerateCodeOnly'), 'off')
    MODEL_SETTINGS.RTWGenerateCodeOnly = 'off';
    set_param(modelName, 'RTWGenerateCodeOnly', 'on');
    DAStudio.warning('RTW:asap2:RTWGenCodeOn');
  end
  
case 'exit'
    if strcmp(get_param(modelName,'GenCodeOnly'),'off')
        msgID = 'RTW:makertw:exitRTWBuild';
    else
        msgID = 'RTW:makertw:exitRTWGenCodeOnly';
    end
    msg = DAStudio.message(msgID,modelName);
    disp(msg);
  
  % Restore property settings as they were before generating ASAP2 file.
  if ~isempty(MODEL_SETTINGS)
    modelPropertiesToRestore = fieldnames(MODEL_SETTINGS);
    for i = 1:length(modelPropertiesToRestore)
      thisProperty = modelPropertiesToRestore{i};
      thisSetting  = MODEL_SETTINGS.(thisProperty);
      set_param(modelName, thisProperty, thisSetting);
      disp(['Restoring: ', thisProperty, ' = ''', thisSetting, '''']);
    end
    MODEL_SETTINGS = [];
  end
end


