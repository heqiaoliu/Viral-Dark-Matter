function val = pSetPathDependencies(job, val)
; %#ok Undocumented
%pSetPathDependencies 
%
%  VAL = pSetPathDependencies(JOB, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/06/24 17:00:47 $ 

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

serializer = job.Serializer;
if ~isempty(serializer)
    try
        % If we are on a PC make sure we convert to a UNC path rather than a
        % locally mapped drive as it is unlikely that the far end will have the
        % same drive mappings on the local system account
        if ispc
            for i = 1:numel(val)
                val{i} = dctReplaceDriveWithUNCPath(val{i});
            end
        end

        serializer.putField(job, 'pathdependencies', val);
    catch e 
        rethrow(e)
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

