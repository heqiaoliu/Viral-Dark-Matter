function [success, message] = rmicheckitem_pre(system)

% Copyright 2009-2010 The MathWorks, Inc.

% When checking items (IDs and labels of individual requirements),
% we need the following:
%    - if there are links to doors, doors login should be available,
%    - if there are links to Word, word should not be running,
%    - if there are links to Excel, excel should not be running.

%fprintf(1, 'rmicheckitem_pre() called for ''%s''\n', get_param(system, 'Name'));

% We will reuse the rmicheckdoc_pre() call to take care of DOORS 
% if links to DOORS documents are present in the model. This will 
% not add much work if DOORS state was already tested by another
% "pre" callback.
[success, message] = rmicheckdoc_pre(system);
if ~success
    return;
end

% Now check for MS Office applications as required for ID and label checks
[success, message] = checkState(system, 'word');
if ~success
    return;
end
[success, message] = checkState(system, 'excel');



function [result, msg] = checkState(sys, app) 

    msg = '';

    app_state = feval('rmi.mdlAdvState', app);
    if app_state == 1 || app_state == -1
        % This should not really happen, because '1' and '-1' are only 
        % possible during Consistency Checking run, but we are in the 
        % 'pre' callaback... but this is fine either way, 
        % '-1' will produce warnings in check results
        result = 1;
        return;
    end
    
    % App status is not set. Check if links to 'app' are present 
    has_app = feval('rmi.mdlAdvState', ['has_' app], sys);
    if has_app
        [result, msg] = doSetup(app);
    else
        result = 1; % no links of this type, app state don't matter
    end
    

function [res, err] = doSetup(my_app)

    setup_ok = feval(['com_' my_app '_check_app'], 'setup');
    if setup_ok
        res = 1; % either 'app' is not running or user does not care
        err = '';
    else
        % User has chosen to Cancel setup dialog,
        % all related checks will be skipped.
        res = 0; 
        err = ['Failed to setup MS ' upper(my_app) ' for Consistency Checking'];
    end


