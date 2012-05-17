function [result, error_str] = dataddg_preapply_callback(dlgH)

% Copyright 2003-2008 The MathWorks, Inc.

  result = 1;
  error_str = '';
  
  if ~ishandle(dlgH)
    return;
  end
  
  h = dlgH.getDialogSource;
  if ~isa(h, 'Stateflow.Data')
    return;
  end
  
  % Remove the tag (if any) identifying this as an intermediate object
  if ~isempty(findstr(h.Tag, '_DDG_INTERMEDIATE_'))
      h.tag = '';
  end
  
  % EML non-tunable parameters can not be variable sized.
  % Dialog itself is constructed in toolbox/stateflow/stateflow/private/dataddg.m
  hasDynamicSize = dlgH.isVisible('sfDatadlg_Props_Array_IsDynamic_checkbox') &&...
                   dlgH.getWidgetValue('sfDatadlg_Props_Array_IsDynamic_checkbox');
  isNonTunableParameter = dlgH.isVisible('sfDatadlg_Tunable_checkbox') &&...
                          ~dlgH.getWidgetValue('sfDatadlg_Tunable_checkbox');
  
  if isNonTunableParameter && hasDynamicSize
      result = 0;
      error_str = DAStudio.message('Stateflow:dialog:NonTunableDynamicSizeParameterNotSupported');
  end
  