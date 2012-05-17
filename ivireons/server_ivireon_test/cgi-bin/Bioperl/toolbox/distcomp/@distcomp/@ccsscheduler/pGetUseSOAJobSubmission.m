function val = pGetUseSOAJobSubmission(ccs, val)
; %#ok Undocumented
% Get the value of UseSOAJobSubmission from the server connection

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:57:59 $

if isempty(ccs.ServerConnection)
    return;
end

try
    % Ask the server connection for the use SOA value
    val = ccs.ServerConnection.UseSOAJobSubmission;
catch err
    % NB set will throw a MATLAB:noPublicFieldForClass, but 
    % get will throw a MATLAB:noSuchMethodOrField error;
    if strcmpi(err.identifier, 'MATLAB:noSuchMethodOrField')
        % SOA jobs aren't supported on this type of scheduler, so
        % just return false
        val = false;
    else
        % Just rethrow if this isn't a noSuchMethodOrField error.
        rethrow(err);
    end
end