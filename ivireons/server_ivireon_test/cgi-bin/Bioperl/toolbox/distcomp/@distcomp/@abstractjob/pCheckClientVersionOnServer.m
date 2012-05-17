function pCheckClientVersionOnServer(job) 
; %#ok Undocumented
%pCheckClientVersion 
%
%  pCheckClientVersion(JOB)
%    Check that the server and client versions match. Either returns or
%    throws an error

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/11/24 14:56:39 $ 

% Test version of job against the local MATLAB
try
    jobVersion = char(job.Serializer.getField(job, 'version'));
    thisVersion = char(com.mathworks.toolbox.distcomp.util.Version.VERSION_STRING);
catch err
    % This probably means we were unable to read the version number from
    % the job so indicate that this is an error
    versionError  = MException('distcomp:job:VersionError', ...
        ['Unable to get version information from job. This probably means\n' ...
         'that the job was created in a client MATLAB prior to the R2009a\n' ...
         'general release, or that the jobdata files of the job are corrupt\n%s'], '');
     versionError = versionError.addCause(err);
     throw(versionError);
end

if ~strcmp(jobVersion, thisVersion)
    versionError = MException('distcomp:job:VersionMismatch', ...
        ['This job was submitted with version %s of the Parallel Computing Toolbox.\n' ...
        'However the current MATLAB Distributed Computing Server is version %s.\n' ...
        'You must run jobs from clients on servers with the same version.\n'], jobVersion, thisVersion);
    throw(versionError);
end
