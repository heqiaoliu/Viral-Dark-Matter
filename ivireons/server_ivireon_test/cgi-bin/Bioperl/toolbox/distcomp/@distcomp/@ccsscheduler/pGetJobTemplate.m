function val = pGetJobTemplate(ccs, val)
; %#ok Undocumented
% Get the job template from the server connection

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:57:56 $

if isempty(ccs.ServerConnection)
    return;
end

try
    % Ask the server connection for the job template value
    val = ccs.ServerConnection.JobTemplate;
catch err
    % NB set will throw a MATLAB:noPublicFieldForClass, but 
    % get will throw a MATLAB:noSuchMethodOrField error;
    if strcmpi(err.identifier, 'MATLAB:noSuchMethodOrField')
        % Job templates aren't supported on this type of scheduler, so
        % just return a ''
        val = '';
    else
        % Just rethrow if this isn't a noSuchMethodOrField error.
        rethrow(err);
    end
end