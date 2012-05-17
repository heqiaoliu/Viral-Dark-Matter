function value = rtw_implementation_props(model)
% RTW_IMPLEMENTATION_PROPERTIES - returns C specific implementation
% properties for a given target inside a MATLAB structure.  For
% example:
%
% value.ShiftRightIntArith   = true;
%
% Example
%   rtw_implementation_props('model_name')
%
% See also EXAMPLE_RTW_INFO_HOOK.
  
% Copyright 1994-2008 The MathWorks, Inc.
% $Revision: 1.2.2.14 $

  cs = getActiveConfigSet(model);
  if strcmp(get_param(cs, 'TargetUnknown'), 'off')
    % Use model param values
    value.ShiftRightIntArith = strcmp(get_param(cs, 'TargetShiftRightIntArith'), 'on');
    value.IntDivRoundTo = get_param(cs,'TargetIntDivRoundTo');
    value.Endianess = get_param(cs, 'TargetEndianess');
    value.TypeEmulationWarnSuppressLevel = get_param(cs, 'TargetTypeEmulationWarnSuppressLevel');
    value.PreprocMaxBitsSint = get_param(cs, 'TargetPreprocMaxBitsSint');
    value.PreprocMaxBitsUint = get_param(cs, 'TargetPreprocMaxBitsUint');
    return;
  end

  % Backwards compatibility support
  hf = rtwprivate('get_rtw_info_hook_file_name',model);
  if hf.FileExists;
    % Use obsoleted hook file
    hookfile = hf.HookFileName;
    try
      value = feval(hookfile,'cImplementation',model);
      % Obsoleted rtw_info_hook did not set these, get from model
      value.IntDivRoundTo = get_param(cs,'TargetIntDivRoundTo');
      value.Endianess = get_param(cs, 'TargetEndianess');
    catch myException
        errID  = 'RTW:buildProcess:hookfileError';
        errText = DAStudio.message(errID, hookfile);
        newExc = MException(errID,errText);
        newExc = newExc.addCause(myException);
        throw(newExc) 
    end
  else
    % hookfile is not available and model is pre-R14; use defaults
    value = rtw_host_implementation_props();
    value.TypeEmulationWarnSuppressLevel = get_param(cs, 'TargetTypeEmulationWarnSuppressLevel');
    value.PreprocMaxBitsSint = get_param(cs, 'TargetPreprocMaxBitsSint');
    value.PreprocMaxBitsUint = get_param(cs, 'TargetPreprocMaxBitsUint');
  end
  
