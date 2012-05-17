function val = pGetClusterOsType(jm, val)  %#ok<INUSD> % takes jobmanager object as input
; %#ok Undocumented
% new property which obtains data as arjav suggestion from
% Jobmanagerserviceinfo object

% Copyright 2006-2008 The MathWorks, Inc.

% $Revision: 1.1.6.2 $  $Date: 2008/03/31 17:07:34 $

val = '';
try
    sInfo = jm.ProxyObject.getServiceInfo;
    workerServiceInfoArray = [sInfo.getIdleWorkers sInfo.getBusyWorkers];
    % workerServiceInfoarry contains all the workers
    % go through all workers to see if there are of mixed Os type
    for i = 1:numel(workerServiceInfoArray)
        workerOsType = char(workerServiceInfoArray(i).getComputerMLType);
        if strncmpi(workerOsType, 'pc', 2) 
            % do test like ispc and isunix
            % if  previous worker is 'Unix', then ostype of cluster is mixed
            if i > 1 && strncmp(val, 'un', 2) 
                val = 'mixed';
                return
            else
                val = 'pc';
            end            
        else
            % if previous worker is 'pc' then ostype is mixed
            if i > 1 && strncmp(val, 'pc', 2)
                val = 'mixed';
                return
            else
                val = 'unix';
            end

        end
    end
catch
    % just return empty OS type if jobmanager object doesn't exist
    val = '' ;
end
