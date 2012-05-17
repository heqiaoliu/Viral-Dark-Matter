function val = pSetJobTemplate(ccs, val)
; %#ok Undocumented
% Set the job template on the server connection

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:58:06 $

if isempty(ccs.ServerConnection)
    return;
end

try
    % Ask the server connection to set the job template.
    ccs.ServerConnection.JobTemplate = val;
catch err
    % NB set will throw a MATLAB:noPublicFieldForClass, but 
    % get will throw a MATLAB:noSuchMethodOrField error;
    if strcmpi(err.identifier, 'MATLAB:noPublicFieldForClass')
        % Job templates aren't supported on this type of scheduler.
        if ~isempty(val)
            % Only default to '' and warn if the user was attempting 
            % to set job template to something other than empty
            val = '';
            warning('distcomp:ccsscheduler:JobTemplatesUnsupported', ...
                'Job Templates are not supported for this type of scheduler.');
        end
    else
        % convert from a ServerConnection error to a ccsscheduler error, if necessary.
        % (Only actually required for distcomp:HPCServerSchedulerConnection:InvalidJobTemplate)
        throw(distcomp.MicrosoftSchedulerConnectionExceptionManager.convertToCCSSchedulerError(err));
    end
end