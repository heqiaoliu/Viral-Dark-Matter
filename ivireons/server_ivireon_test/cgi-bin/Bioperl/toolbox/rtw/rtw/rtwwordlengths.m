function value = rtwwordlengths(model)
% RTWWORDLENGTHS - returns the word lengths for a given target.
% For example,
%
% value.CharNumBits  = int32(8);
% value.ShortNumBits = int32(16);
% value.IntNumBits   = int32(32);
% value.LongNumBits  = int32(32);
%
% Example
%   rtwwordlengths('model_name')
%
% See also EXAMPLE_RTW_INFO_HOOK.
  
% Copyright 1994-2008 The MathWorks, Inc.
% $Revision: 1.2.2.15 $

  cs = getActiveConfigSet(model);
  if strcmp(get_param(cs, 'TargetUnknown'), 'off')        
    % Use model param values
    value.CharNumBits  = int32(get_param(cs, 'TargetBitPerChar'));
    value.ShortNumBits = int32(get_param(cs, 'TargetBitPerShort'));
    value.IntNumBits   = int32(get_param(cs, 'TargetBitPerInt'));
    value.LongNumBits  = int32(get_param(cs, 'TargetBitPerLong'));
    value.WordSize     = int32(get_param(cs, 'TargetWordSize'));
    return;
  end

  % Backwards compatibility support
  hf = rtwprivate('get_rtw_info_hook_file_name',model);
  if hf.FileExists;
    % hook file is available
    hookfile = hf.HookFileName;
    try
      value = feval(hookfile,'wordlengths',model);
    catch myException
        errID  = 'RTW:buildProcess:hookfileError';
        errText = DAStudio.message(errID, hookfile);
        newExc = MException(errID,errText);
        newExc = newExc.addCause(myException);
        throw(newExc) 
    end
    if ~isfield(value,'CharNumBits') || ...
            ~isfield(value,'ShortNumBits') || ...
            ~isfield(value,'IntNumBits') || ...
            ~isfield(value,'LongNumBits')
        DAStudio.error('RTW:buildProcess:invalidWordlengthinHookfile',...
                       hookfile);
    end
    value.CharNumBits  = int32(value.CharNumBits);
    value.ShortNumBits = int32(value.ShortNumBits);
    value.IntNumBits   = int32(value.IntNumBits);
    value.LongNumBits  = int32(value.LongNumBits);
    % WordSize maps to Long for backwards compatibility
    value.WordSize     = value.LongNumBits;
  else
    % hookfile is not available and model is pre-R14; use defaults
    value = rtwhostwordlengths();
  end
