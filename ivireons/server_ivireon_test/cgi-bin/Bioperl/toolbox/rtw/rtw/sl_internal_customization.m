function sl_internal_customization(cm)
% SL_INTERNAL_CUSTOMIZATION
% Register RTW.TargetRegistry obj and method with cm
% 
% Usage: 
%    cm.registerTargetInfo(TargetInfoObj)
% Note:
%    TargetInfoObj must be of type RTW.TflRegistry

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.5 $


% register TargetRegistryInfo API with Customization Manager
cm.addCustomizer('registerTargetInfo', @registerTargetInfo);
RTW.TargetRegistry.getInstance('reset');
cm.registerTargetInfo(@getrtwDefaultTargetInfo);

% End of sl_internal_customization

% Local functions

% ===================== registerTargetInfo utility ======================
function registerTargetInfo(tgtInfoObj)
% get the current TR handle.
tr = RTW.TargetRegistry.getInstance('simulinkstart');
tr.registerTargetInfo(tgtInfoObj);
% EOF
