function val = pGetFailedAttemptInformation(task, val)
; %#ok Undocumented
%PGETFAILEDATTEMPTINFORMATION Retrieves the task info of all rerun attempts
%
%  VAL = PGETFAILEDATTEMPTINFORMATION(TASK, VAL)

%  Copyright 2008-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2009/03/05 18:46:38 $


try
    if task.HasProxyObject
        array = task.ProxyObject.getFailedAttemptInformation(task.UUID);
        if numel(array) > 0
            taskInfos = array(1);
            val = handle( -ones(numel(taskInfos), 1) );
            for i = 1:numel(taskInfos)
                val(i) = distcomp.failedattemptinformation(taskInfos(i));
            end
        end
    end
catch err %#ok<NASGU>
    % Do not throw any errors.
end
end
