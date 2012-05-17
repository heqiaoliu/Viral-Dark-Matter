function invoke_rtwbuild_custom_hook(h,hook,dependencyObject)
% INVOKE_RTWBUILD_CUSTOM_HOOK: Invoke additional RTW build custom 
% hooks (calbacks) to the normal Real-Time Workshop build process.
%

% Copyright 1994-2008 The MathWorks, Inc.
% $Revision: 1.1.6.5 $

modelName = h.ModelName;

hcustom = sldowprivate('cusattic','AtticData', 'RTWBuildCustomizations');
if ~isempty(hcustom) && ~isempty(hcustom.(hook))
    if strcmp(get_param(modelName, 'RTWVerbose'),'on')
        disp(['### Invoking Real-Time Workshop build custom ', hook,' hook']);
    end
    i_callHook(modelName, hcustom.(hook), dependencyObject);   
end

% call Link for TASKING make_rtw_hook for appropriate models
% required because Link for TASKING is not associated with a system target 
% file and so doesn't have regular make_rtw hooks
cs = getActiveConfigSet(modelName);
if cs.isValidParam('TaskingConfiguration')
    l4tHook = ['tasking_make_rtw_hook(''' hook ...
               ''', modelName, dependencyObject)'];
    i_callHook(modelName, ...
               l4tHook, ...
               dependencyObject);
end

%%%%%%%%%%%%%%%%%%%%
function i_callHook(modelName, hook, dependencyObject)
try
    evalfunc(hook,modelName,dependencyObject);
catch exc
    % the original error message is formatted with various HTML
    % formatting and possible drive letter specification.  clean it
    % up before including it
    errMsg = rtwprivate('escapeOriginalMessage',exc);
    errID = 'RTW:buildProcess:invalidRTWBuildCustomization';
    errMsg = DAStudio.message(errID, hook,errMsg);
    
    newExc = MException(errID, errMsg);
    newExc = newExc.addCause(exc);
    throw(newExc);
end

%%%%%%%%%%%%%%%%%%%%
function evalfunc(commandToEval, modelName, dependencyObject) %#ok<INUSD>
% Do the eval in a clean workspace

eval(commandToEval);

%EOF
