function [MLDTOSetting,MLDTOAppliesToSetting,errMsg] = eml_fipref_helper(dtoStr,dtoAppliesToStr)
% Helper function to be used only in eML fi constructor to modify DTO settings

%   Copyright 2006-2010 The MathWorks, Inc.
    
fp = fipref;
MLDTOSetting = fp.DataTypeOverride;
MLDTOAppliesToSetting = fp.DataTypeOverrideAppliesTo;
errMsg = '';
dtoStr = lower(dtoStr);
switch dtoStr
  case {'forceoff','off'}
    fp.DataTypeOverride = 'ForceOff';
  case 'scaleddoubles'
    fp.DataTypeOverride = 'ScaledDoubles';
  case 'truedoubles'
    fp.DataTypeOverride = 'TrueDoubles';
  case 'truesingles'
    fp.DataTypeOverride = 'TrueSingles';
  case 'unknown'
    errMsg = 'Unknown Fixed-point DataTypeOverride setting.';
    return;
  otherwise
    errMsg = ['The Fixed-point DataTypeOverride setting ', dtoStr , ' is not supported.'];
    return;
end

dtoAppliesToStr = lower(dtoAppliesToStr);
switch dtoAppliesToStr
  case {'allnumerictypes'}
    fp.DataTypeOverrideAppliesTo = 'AllNumericTypes';
  case {'fixed-point'}
    fp.DataTypeOverrideAppliesTo = 'Fixed-point';
  case {'floating-point'}
    fp.DataTypeOverrideAppliesTo = 'Floating-point';
  otherwise
    errMsg = ['The Fixed-point DataTypeOverrideAppliesTo seeting ', dtoAppliesToStr, ' is not supported.'];
    return;
end

%-------------------------------------------------------------------------------------------------------

    
    
