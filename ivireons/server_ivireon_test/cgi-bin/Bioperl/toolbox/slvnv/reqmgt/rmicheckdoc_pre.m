function [success, message] = rmicheckdoc_pre(system)

% Copyright 2009-2010 The MathWorks, Inc.

% Ensure correct environment state for rmicheckdoc procedure.
% If the model has DOORS links, we'll need to request that DOORS is
% avalialbe, or the check can not proceed.

%fprintf(1, 'rmicheckdoc_pre() called for ''%s''\n', get_param(system, 'Name'));

message = '';

doors_state = rmi.mdlAdvState('doors');

if doors_state == 1 || doors_state == -1
    % Doors state has been tried already. We are OK to proceed eather way,
    % if state is '-1', warnings will be displayed in the report
    success = 1;
    
else % doors_state == 0 means unset
    
    % Probe the model for links to DOORS
    has_doors = rmi.mdlAdvState('has_doors', system);
    if has_doors
        [success, message] = checkDoorsLogin(); % we do need DOORS login
    else
        rmi.mdlAdvState('doors', -1); % no DOORS reqs, assume no DOORS login as this won't matter
        success = 1;
    end
    
    
end

function [out, msg] = checkDoorsLogin()
    if is_doors_running('consistency check')
        rmi.mdlAdvState('doors', 1); % all good, or the user chose to continue without doors.
        out = 1;
        msg = '';
    else % Doors unavailable, all related checks will be canceled.
        out = 0; 
        msg = 'Doors unavailable';
        
        % Don't ask about DOORS again until the next run of Model Advisor.
        % Note that this allows other checks to proceed and display partial
        % results, which makes most sense when executed in normal order:
        % document check followed by ID ad label checks.
        % Warning about unchecked DOORS links will also be displayed.
        rmi.mdlAdvState('doors', -1); 
    end
