function ok = updateBlockParameter(hBlk,params,strVal,options)
% UPDATEBLOCKPARAMETER  updates block parameters 
%
% Input:
%
%   hBlk    - full block path
%   params  - block parameters that need to be updated 
%   strVal  - new values to be written back to block
%   options - (optional) structure regarding warning message dialog
%               ShowWarningDlg: true/false
%               WarningMsgIDWithVar: full message ID used by the warning dialog when there is at least one variable.
%               WarningMsgIDNoVar: full message ID used by the warning dialog when there is no variable.
%               WarningTitleID: full title ID used by the warning dialog
% Output:
%
%   ok      - return true if block gets updated.

% Author(s): Rong Chen 22-Mar-2010
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:08 $

%% Detect whether the current expression in the block dialog is can be resolved as a variable
nP = numel(params);
IsVariable = false(nP,1);
wksp = cell(nP,1);
% loop through each parameter
for ct=1:nP
    param = params{ct};
    try  %#ok<*TRYNC>
        wks = slResolve(get_param(hBlk,param),hBlk,'context');
        IsVariable(ct) = true;
        wksp{ct} = wks;
    end
end

%% Prompt user to update block/variable
if nargin==3 || ~options.ShowWarningDlg
    ok = true;
else
    if any(IsVariable)
        %At least one of the parameters defines a workspace variable.
        idx = find(IsVariable);
        strVariable = get_param(hBlk,params{idx(1)});
        for ct = 2:numel(idx)
            strVariable = strcat(strVariable,', ',get_param(hBlk,params{idx(ct)}));
        end
        btn = questdlg(...
            ctrlMsgUtils.message(options.WarningMsgIDWithVar,strVariable), ...
            ctrlMsgUtils.message(options.WarningTitleID),...
            ctrlMsgUtils.message('Slcontrol:pidtuner:yes'),...
            ctrlMsgUtils.message('Slcontrol:pidtuner:no'),...
            ctrlMsgUtils.message('Slcontrol:pidtuner:yes'));
    else
        %None of the parameters are variables, overwrite the block string
        btn = questdlg(...
            ctrlMsgUtils.message(options.WarningMsgIDNoVar), ...
            ctrlMsgUtils.message(options.WarningTitleID),...
            ctrlMsgUtils.message('Slcontrol:pidtuner:yes'),...
            ctrlMsgUtils.message('Slcontrol:pidtuner:no'),...
            ctrlMsgUtils.message('Slcontrol:pidtuner:yes'));
    end
    ok = strcmp(btn,ctrlMsgUtils.message('Slcontrol:pidtuner:yes'));
end

%% Update block parameters
if ok
    for ct = 1:nP
        if IsVariable(ct)
            %Block parameter defines a variable that can be updated
            var = get_param(hBlk,params{ct});
            if strcmp(wksp{ct},'Global')
                if evalin('base',['isa(' var ',''Simulink.Parameter'')'])
                    evalin('base',[var, '.Value=', strVal{ct}, ';']);
                else
                    assignin('base',var,eval(strVal{ct}));
                end
            else
                mwksp = get_param(bdroot(hBlk),'ModelWorkspace');
                if evalin(mwksp,['isa(' var ',''Simulink.Parameter'')'])
                    evalin(mwksp,[var, '.Value=', strVal{ct}, ';']);
                else
                    assignin(mwksp,var,eval(strVal{ct}));
                end
            end
        else
            %Parameter value is not a variable or cannot be recognized as a
            %variable, replace with numeric values
            set_param(hBlk,params{ct},strVal{ct});
        end
    end
end


