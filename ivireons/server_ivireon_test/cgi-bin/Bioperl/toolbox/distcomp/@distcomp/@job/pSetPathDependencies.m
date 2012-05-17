function val = pSetPathDependencies(job, val)
; %#ok Undocumented
%pSetPathDependencies A short description of the function
%
%  VAL = pSetPathDependencies(JOB, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/06/24 17:01:22 $

if job.IsBeingConstructed
    % Whilst the job is being constructed we need to ensure that we concatenate
    % the PathDependencies rather than overwrite the existing ones. We can safely
    % store the values in the actual field until after construction.
    
    % The post function is stored with the value to set 
    postFcn = @iPostConstructionSetPathDependencies;
    % Have we already set this post construction function once?
    [index, oldVal, oldConfig] = job.pFindPostConstructionFcn(postFcn);
    % Which configuration is being used to set us
    newConfig = job.ConfigurationCurrentlyBeingSet;
    if isempty(index)
        job.pAddPostConstructionFcn(postFcn, val, newConfig);
    else
        newConfig = distcomp.configurableobject.pGetConfigNameFromConfigPair(oldConfig, newConfig);
        job.pModifyPostConstructionFcn(index, postFcn, [oldVal ; val], newConfig);
    end
    val = {};
    return
end

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        % If we are on a PC make sure we convert to a UNC path rather than a
        % locally mapped drive as it is unlikely that the far end will have the
        % same drive mappings on the local system account
        if ispc
            for i = 1:numel(val)
                val{i} = dctReplaceDriveWithUNCPath(val{i});
            end
        end

        if ~isempty(val)
            % Need to ensure the cell array of strings is 1 x nStrings
            % otherwise the java layer gets upset
            val = reshape(val, 1, numel(val));
        else
            % Need to make a 1 x 0 array of java.lang.String[][]
            val = javaArray('java.lang.String', 1, 1);
            val(1) = '';
        end
        proxyJob.setPathList(job.UUID, val);
    catch err
        throw(distcomp.handleJavaException(job, err));
    end
end
% Do not hold anything locally
val = {};

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function iPostConstructionSetPathDependencies(job, val, config)
% Actually set the file dependencies
pSetPropertyAndConfiguration(job, 'PathDependencies', val, config);
