function val = pSetUseSOAJobSubmission(ccs, val)
; %#ok Undocumented
% Sets the UseSOAJobSubmission property and updates the server connection with this value.
% Since this property is available for all ccsscheduler objects, regardless of the actual
% scheduler version, this property will only be set to true if the current server connection
% supports SOA jobs (i.e. the server connection is a v2 connection).

%  Copyright 2008-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $ $Date: 2009/04/15 22:58:08 $

if isempty(ccs.ServerConnection)
    return
end

try
    % Ask the server connection to set the use SOA option
    ccs.ServerConnection.UseSOAJobSubmission = val;
catch err
    % NB set will throw a MATLAB:noPublicFieldForClass, but 
    % get will throw a MATLAB:noSuchMethodOrField error;
    if strcmpi(err.identifier, 'MATLAB:noPublicFieldForClass')
        % SOA jobs aren't supported on this type of scheduler.
        if val == true
            % Only default to false and warn if the user was attempting 
            % to set UseSOA to true.
            val = false;
            warning('distcomp:ccsscheduler:SOAJobsUnsupported', ...
                'SOA Job Submission is not supported for this type of scheduler.  Defaulting to non SOA jobs.');
        end
    else
        % Just rethrow if this isn't a MATLAB:noPublicFieldForClass error.
        rethrow(err);
    end
end